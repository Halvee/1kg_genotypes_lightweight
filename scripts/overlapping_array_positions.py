

import argparse

def main():

    # parse user arguments
    parser = argparse.ArgumentParser(description='Get overlapping SNP positions from a set ' + \
                                                 'of Illumina genotype array Physical-and-Genetic-Coordinates.txt files.')
    parser.add_argument('--chromosomes-keep', type=str, action='store',
                        help='set of chromosomes to include in overlaps',
                        default='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y')
    parser.add_argument('--use-snpid-in-dictionary', action='store_true',
                        default=False,
                        help='instead of (chr,pos), use (chr,pos,snpid) in dictionary across files.')
    parser.add_argument('--random-seed', type=int,
                        default=None, help='random seed integer')
    parser.add_argument('--min-fraction-datasets-overlap', type=float,
                        default=1.0, help='Minimum fraction of datasets a SNP position has to be found in for inclusion')
    parser.add_argument('--output-tsv', type=str, default='output.tsv',
                        help='tab-delim output file with SNP positions overlapping between min. specified files')
    parser.add_argument('phys_genet_coord_files', type=str, nargs='+',
                         help='input Illumina genotype array Physical-and-Genetic-Coordinates.txt files.')
    args = parser.parse_args()

    # get total number of array files and define as the total number of arrays
    n_arrays = len(args.phys_genet_coord_files)

    # get chromosomes to keep
    chroms_keep = set(args.chromosomes_keep.split(","))

    # define a dictionary for storing chrom + position (and snp name if desired by user)
    chrpos_counts_dict = dict()

    # for each input file ..
    for i in range(n_arrays):
        
        # open filehandle to single input file
        file_i = args.phys_genet_coord_files[i]
        fh_i = open(file_i, "r")

        # get header line
        headerline = fh_i.readline()

        # for each line, store to dictionary
        for line in fh_i:
            data =line.rstrip().split()
            snpid = data[0]
            chrom = data[1]
            pos = data[2]
            genet_pos = data[3]

            # skip if chromosome is not one to keep
            if chrom not in chroms_keep: 
                continue

            # define chr/pos to store (or chr/pos/snpid if desired by user)
            to_store_i = [chrom, pos]
            if args.use_snpid_in_dictionary == True:
                to_store_i = (chrom, pos, snpid)
            else:
                to_store_i = (chrom, pos, chrom+":"+pos)

            # store snp pos info to dictionary if not there yet
            if to_store_i not in chrpos_counts_dict:
                chrpos_counts_dict[to_store_i] = 0

            # increment count of snp pos info
            chrpos_counts_dict[to_store_i] += 1

        # close filehandle
        fh_i.close()

    # for each distinct snp chr/pos processed ..
    for to_store_i in chrpos_counts_dict.keys():

        # get total number of times snp chr/pos detected
        n_arrays_i = chrpos_counts_dict[to_store_i]
        
        # get percent of total arrays snp chr/pos detected
        perc_arrays_i = n_arrays_i / float(n_arrays)

        # keep snp if min percent of array criteria met
        if perc_arrays_i >= args.min_fraction_datasets_overlap:

            # if snp is kept, print output as plink positional ranges
            range_out = [to_store_i[0], to_store_i[1],
                         to_store_i[1],to_store_i[2]]
            out = "\t".join(range_out)
            print(out)

    return


if __name__ == "__main__":
    main()
