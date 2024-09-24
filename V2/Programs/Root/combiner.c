#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

void main(int argc, char **argv) {
	uint8_t buffer[8192];
	FILE *outfile = fopen("combined.bin", "wb");
	if(!outfile) {
		printf("Failed to open output file\n");
		exit(1);
	}
	uint32_t totalWritten = 0;
	buffer[0] = 'C';
	buffer[1] = 'H';
	buffer[2] = 'I';
	buffer[3] = 'R';
	buffer[4] = 'P';
	buffer[5] = '!';
	buffer[6] = 0;
	fwrite(buffer, 1, 7, outfile);
	for(int i = 1; i < argc; i++) {
		FILE *infile = fopen(argv[i], "rb");
		if(!infile) {
			printf("failed to open input file \"%s\".", argv[i]);
			exit(1);
		}
		memset(buffer, 0, 8192);
		fread(buffer, 1, 8192, infile);
		fwrite(buffer, 1, i == 1 ? (8192 - 7) : 8192, outfile);
		totalWritten += 8192;
		while(i == argc - 1) {
			//Last entry may be arbitrarily long
			memset(buffer, 0, 8192);
			int read = fread(buffer, 1, 8192, infile);
			if(read == 0) break;
			fwrite(buffer, 1, read, outfile);
			totalWritten += read;
		}
		fclose(infile);
	}
	const uint32_t target = 8*1024*1024;
	memset(buffer, 0xFF, 8192);
	while(totalWritten < target) {
		uint32_t diff = target - totalWritten;
		fwrite(buffer, 1, diff < 8192 ? diff : 8192, outfile);
		totalWritten += 8192;
	}
	fclose(outfile);
}
