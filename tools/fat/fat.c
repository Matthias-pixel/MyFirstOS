#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
typedef uint8_t bool;
#define true 1
#define false 0
typedef struct {
    uint8_t BootJumpInstruction[3];
    uint8_t OemIdentifier[8];
    uint16_t BytesPerSector;
    uint8_t SectorsPerCluster;
    uint16_t ReservedSectors;
    uint8_t FatCount;
    uint16_t DirEntryCount;
    uint16_t TotalSectors;
    uint8_t MediaDescriptorType;
    uint16_t SectorsPerFat;
    uint16_t SectorsPerTrack;
    uint16_t Heads;
    uint32_t HiddenSectors;
    uint32_t LargeSectorCount;

    uint8_t DriveNumber;
    uint8_t _Reserved;
    uint8_t Signature;
    uint32_t VolumeId;
    uint8_t VolumeLabel[11];
    uint8_t SystemId[8];
} __attribute__((packed)) BootSector;
typedef struct {
    uint8_t Name[11];
    uint8_t Attributes;
    uint8_t _Reserved;
    uint8_t CreatedTimeTenths;
    uint16_t CreatedTime;
    uint16_t CreatedDate;
    uint16_t AccessedDate;
    uint16_t FirstClusterHigh;
    uint16_t ModifiedTime;
    uint16_t ModifiedDate;
    uint16_t FirstClusterLow;
    uint32_t Size;
} __attribute__((packed)) DirectoryEntry;

BootSector g_BootSector;
uint8_t* g_Fat = NULL;
DirectoryEntry* g_RootDirectory = NULL;
uint32_t g_ClusterStart;

bool readBootSector(FILE* disk) {
    return fread(&g_BootSector, sizeof(BootSector), 1, disk) > 0;
}
bool readSectors(FILE* disk, uint32_t start, uint32_t count, void* bufferOut) {
    bool ok = true;
    ok = ok && (fseek(disk, start*g_BootSector.BytesPerSector, SEEK_SET) == 0);
    ok = ok && (fread(bufferOut, g_BootSector.BytesPerSector, count, disk) == count);
    return ok;
}
bool readFat(FILE* disk) {
    g_Fat = (uint8_t*) malloc(g_BootSector.SectorsPerFat*g_BootSector.BytesPerSector);
    return readSectors(disk, g_BootSector.ReservedSectors, g_BootSector.SectorsPerFat, g_Fat);
}
bool readRootDirectory(FILE* disk) {
    uint32_t start = g_BootSector.ReservedSectors+g_BootSector.SectorsPerFat*g_BootSector.FatCount;
    uint32_t size = sizeof(DirectoryEntry)*g_BootSector.DirEntryCount;
    uint32_t sectors = size/g_BootSector.BytesPerSector;
    if(size%g_BootSector.BytesPerSector > 0)
        sectors++;
    g_ClusterStart = start+sectors;
    g_RootDirectory = malloc(sectors*g_BootSector.BytesPerSector);
    return readSectors(disk, start, sectors, g_RootDirectory);
}
DirectoryEntry* findFile(const char* name) {
    for(int i = 0; i < g_BootSector.DirEntryCount; i++) {
        if(memcmp(name, g_RootDirectory[i].Name, 11) == 0) return &g_RootDirectory[i];
    }
    return NULL;
}
bool readFile(DirectoryEntry* fileEntry, FILE* disk, uint8_t* outputBuffer) {
    bool ok = true;
    uint32_t currentCluster = fileEntry->FirstClusterLow;
    while(ok && currentCluster < 0xFF8) {
        ok = ok && readSectors(disk, g_ClusterStart+(currentCluster-2)*g_BootSector.SectorsPerCluster, g_BootSector.SectorsPerCluster, outputBuffer);
        outputBuffer += g_BootSector.SectorsPerCluster*g_BootSector.BytesPerSector;
        uint32_t fatIndex = currentCluster * 3 / 2;
        if (currentCluster % 2 == 0)
            currentCluster = (*(uint16_t*)(g_Fat + fatIndex)) & 0x0FFF;
        else
            currentCluster = (*(uint16_t*)(g_Fat + fatIndex)) >> 4;
    }
    return ok;
}


int main(int argc, char** argv) {
    if(argc < 3) {
        printf("Syntax: %s <disk image> <file name>\n", argv[0]);
        return -1;
    }
    FILE* disk = fopen(argv[1], "rb");
    if(!disk) {
        fprintf(stderr, "Cannot read disk image %s!\n", argv[1]); return -1;
    }
    if(!readBootSector(disk)) {
        fprintf(stderr, "Couldn't read boot sector!\n"); return -2;
    }
    if(!readFat(disk)) {
        free(g_Fat);
        fprintf(stderr, "Couldn't read File Allocation Table!\n"); return -3;
    }
    if(!readRootDirectory(disk)) {
        free(g_Fat);
        free(g_RootDirectory);
        fprintf(stderr, "Couldn't read Root Directory!\n"); return -4;
    }
    DirectoryEntry* myFile = findFile(argv[2]);
    if(myFile == NULL) {
        free(g_Fat);
        free(g_RootDirectory);
        fprintf(stderr, "Couldn't find file %s!\n", argv[2]); return -5;
    }
    uint8_t* buffer = malloc(myFile->Size+g_BootSector.BytesPerSector);
    if(!readFile(myFile, disk, buffer)) {
        free(buffer);
        free(g_Fat);
        free(g_RootDirectory);
        fprintf(stderr, "Couldn't read file %s!\n", argv[2]); return -5;
    }
    printf("%s", buffer);
    free(buffer);
    free(g_Fat);
    free(g_RootDirectory);
    return 0;
}