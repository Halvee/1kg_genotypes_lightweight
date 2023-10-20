
import sys
import argparse

def main():

    # user args
    parser = argparse.ArgumentParser(description='format BIM file SNP IDs for merger of test and reference PLINK bed/bim/fam files')
    parser.add_argument('reference_dataset_bim', type=str,
                        help='filepath to PLINK bim file for reference dataset.')
    parser.add_argument('test_dataset_bim', type=str,
                        help='filepath to PLINK bim file for test dataset.')
    parser.add_argument('test_dataset_bim_out', type=str,
                        help='filepath to PLINK bim file for test dataset to write with snpids matched to ref dataset.')
    parser.add_argument('testsnpid_refsnpid_tsv', type=str,
                        help='tab delim output file where col1 is test dataset snpid, col2 is ref dataset snpid')
    args = parser.parse_args()

    # read reference dataset bim, store (snpid, chr, pos, alleles)
    ref_bim_fh = open(args.reference_dataset_bim, "r")
    ref_bim_dict = dict()
    for line in ref_bim_fh:

        # from line, get (chrom, pos, allele1, allele2) where alleles are sorted
        # alphabetically
        snpid, snp_info = parse_bim_line(line)
        
        # store to dictionary
        ref_bim_dict[tuple(snp_info)] = snpid

    # close filehandle
    ref_bim_fh.close()

    # open filehandle for test bim
    test_bim_fh = open(args.test_dataset_bim, "r")

    # for each line in test dataset bim, if chr/pos/alleles found in reference dataset bim, store to 
    # dictionary of testsnpid -> refsnpid and store line with testsnpid -> refsnpid
    snpids_test_keep = set()
    for line in test_bim_fh:

        # from line, get (chrom, pos, allele1, allele2) where alleles are sorted
        # alphabetically
        snpid_test, snp_info = parse_bim_line(line)

        # is snp info found in reference bim set? If not, flip alleles strand
        # and try again
        snpid_ref = None
        snp_info_tup = tuple(snp_info)
        if snp_info_tup in ref_bim_dict:
            snpid_ref = ref_bim_dict[snp_info_tup]
        else:
            snp_info[2] = flip_allele(snp_info[2])
            snp_info[3] = flip_allele(snp_info[3])
            snp_info_tup = tuple(snp_info)
            if snp_info_tup in ref_bim_dict:
                snpid_ref = ref_bim_dict[snp_info_tup]

        # swap ids if equivalent snp found in ref dataset
        if snpid_ref != None:
            snpids_test_keep.add(snpid_test)

    # reset reading of test bim file
    test_bim_fh.seek(0)

    # init output files
    bim_out_fh = open(args.test_dataset_bim_out, "w")
    translation_fh = open(args.testsnpid_refsnpid_tsv, "w")

    # write test dataset bim and translation file with testsnpid -> refsnpid
    for line in test_bim_fh:
        data = line.rstrip().split()
        snpid_test, snp_info = parse_bim_line(line)
        if snpid_test in snpids_test_keep:
            snpid_ref = ref_bim_dict[tuple(snp_info)]
            data[1] = snpid_ref
            line_out = "\t".join(data)
            bim_out_fh.write(line_out+"\n")
            translation_fh.write(snpid_test + "\t" + snpid_ref+ "\n")
        else:
            bim_out_fh.write(line)

    # close filehandles
    bim_out_fh.close()
    translation_fh.close()

    return

def parse_bim_line(line):
    data = line.rstrip().split()
    chrom = data[0]
    snpid = data[1]
    pos = data[3]
    a1 = data[4]
    a2 = data[5]

    # get a1 and a2 and sort in alphabetical order
    alleles = [a1, a2]
    alleles.sort()
        
    # store to array, return
    snp_info = [chrom, pos, alleles[0], alleles[1]]
    return snpid, snp_info

def flip_allele(a1):
    alleles = {"A":"T", "G":"C",
               "T":"A", "C":"G",
               "a":"t", "g":"c",
               "t":"a", "c":"g"}
    try:
        a2 = alleles[a1]
    except:
        print("ERROR : non-ACGT allele detected ("+a1+")")
        sys.exit(1)

    return a2

if __name__ == "__main__":
    main()
