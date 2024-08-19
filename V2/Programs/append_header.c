#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <argp.h>
#include <string.h>

static struct argp_option options[] = {
	{ "if", 'i', "FILE", 0, "Input file" },
	{ "of", 'o', "FILE", 0, "Output file" },
	{ 0 }
};

struct arguments {
	char *input_file;
	char *output_file;
};

static error_t parse_opt(int key, char *arg, struct argp_state *state) {
	struct arguments *arguments = state->input;
	
	switch(key) {
		case 'i':
			arguments->input_file = arg;
			break;
		case 'o':
			arguments->output_file = arg;
			break;
		default:
			return ARGP_ERR_UNKNOWN;
	}
	return 0;
}

static struct argp argp = { options, parse_opt, 0, 0 };

int main(int argc, char **argv) {
	struct arguments arguments;
	arguments.input_file = 0;
	arguments.output_file = 0;
	argp_parse(&argp, argc, argv, 0, 0, &arguments);
	if(arguments.input_file == 0 || arguments.output_file == 0) {
		printf("Missing required arguments\n");
		return 1;
	}
	FILE *infile = fopen(arguments.input_file, "rb");
	FILE *outfile = fopen(arguments.output_file, "wb");
	int total_written = fwrite("CHIRP!", 1, 7, outfile);
	uint8_t buff[128];
	while(1) {
		int read = fread(buff, 1, 128, infile);
		if(read == 0) break;
		fwrite(buff, 1, read, outfile);
		total_written += read;
	}
	fclose(infile);
	memset(buff, 0, 128);
	while(total_written != 65536) {
		total_written += fwrite(buff, 1, 65536 - total_written < 128 ? 65536 - total_written : 128, outfile);
	}
	fclose(outfile);
	return 0;
}
