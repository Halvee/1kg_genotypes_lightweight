

import sys
import argparse
import gzip

def main():

    parser = argparse.ArgumentParser(description='Skeleton python script.')
    parser.add_argument('--full-stats', action='store_true',
                        default=False,
                        help='return full stats to standard output.')
    parser.add_argument('--builds', type=str, action='store',
                        default='hg11,hg12,hg13,hg15,hg16,hg17,hg18,hg19,hg38',
                        help='human ref genome build versions to test')
    parser.add_argument('--build-coord-tsv', type=str, action='store',
                        default=sys.path[0] + '/data/buildcheck.rsid_coordinates.tsv',
                        help='table containing coord info per hg build.')
    parser.add_argument('--nonambiguous-snps-only', 
                        action='store_true', default=False,
                        help='only store info for SNPs that are not ' + \
                             'A/T, G/C')
    parser.add_argument('--info-field-delim', type=str, action='store',
                        default=';',
                        help='delimiter used for info field.')
    parser.add_argument('--info-keyval-delim', type=str, action='store',
                        default='=',
                        help='delimiter used for info key/value pairs.')
    parser.add_argument('--allele-freq-info-key', type=str, action='store',
                        default='AF',
                        help='name of allele frequency field to look for in INFO')
    parser.add_argument('--allele-freq-min', type=float, action='store',
                        default=None,
                        help='minimum allele frequency required for inclusion')
    parser.add_argument('--allele-freq-max', type=float, action='store',
                        default=None,
                        help='minimum allele frequency required for inclusion')
    parser.add_argument('--flags-require-present', type=str, action='store',
                        default=None,
                        help='comma-delimited set of flags that must be '+\
                              'present for variant inclusion')
    parser.add_argument('--flags-require-absent', type=str, action='store',
                        default=None,
                        help='comma-delimited set of flags that must be '+\
                              'absent for variant inclusion')
    parser.add_argument('--variant-type', type=str, action='store',
                        choices=('SV','INDEL','SNP'),
                        default='SNP',
                        help='variant type to extract from data ' + \
                             '(choices: SV, INDEL, SNP)')
    parser.add_argument('--chromosomes-keep', type=str, action='store',
                        default='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22',
                        help='comma-delimited set of chromosomes to keep')
    parser.add_argument('--keep-original-snpid', action='store_true',
                        default=False,
                        help="don't overwrite original snpid with chr-pos-ref-alt")
    parser.add_argument('--output-plink-range', action='store_true',
                        default=False,
                        help='output file in form of PLINK "range" file')
    parser.add_argument('--chrom-pos-keep', action='store', type=str,
                        default=None,
                        help='whitespace-delim file where col1 is chromosome, '+\
                             'col2 is position, and you only keep SNPs falling '+\
                             'within these sites.')
    parser.add_argument('in_pvar_vcf', type=str,
                        help='input PLINK2 pvar or VCF (can be bgzipped, or listed as stdin).')
    parser.add_argument('out_list', type=str,
                        help='output list text file (can be gzipped)')
    args = parser.parse_args()

    # open filehandle to read vcf
    if args.in_pvar_vcf.find(".gz") != -1:
        in_fh = gzip.open(args.in_pvar_vcf, "rt")
    elif args.in_pvar_vcf == "stdin":
        in_fh = sys.stdin
    else:
        in_fh = open(args.in_pvar_vcf, "r")

    # get flags required to be present, absent
    flags_require_present=[]
    if args.flags_require_present!=None:
        flags_require_present = args.flags_require_present.split(",")
    flags_require_absent=[]
    if args.flags_require_absent!=None:
        flags_require_absent = args.flags_require_absent.split(",")

    # init set of chromosomes to keep
    chromosomes_keep = set(args.chromosomes_keep.split(","))

    # init list of rsids to keep
    snpids_keep = []

    # for each line ..
    for line in in_fh:
        
        # skip if line is not a VCF entry 
        if line[0] == "#":
            continue

        # get VCF items
        data = line.rstrip().split("\t")
        [chrom, pos, snpid, ref, alt,
         qual, filterstatus, info] = data[:8]

        # only proceed if chromosome is in predefined set of chroms to keep
        if chrom not in chromosomes_keep:
            continue

        # dig into info data, get key/val pairs
        info_keyvals = info.split(args.info_field_delim)
        
        # store info key/val data to dict
        keyvals=dict()
        for info_keyval in info_keyvals:
            keyval = info_keyval.split(args.info_keyval_delim)
            if len(keyval) == 1:
                keyvals[keyval[0]] = True
            else:
                keyvals[keyval[0]] = keyval[1]

        # skip if variant type does not match
        if keyvals['VT'] != args.variant_type:
            continue

        # if desired by user, and variant is SNP, filter on ambiguous snps 
        if args.nonambiguous_snps_only == True and keyvals['VT'] == "SNP":
            refalt = ref+alt
            if refalt in set(['AT','TA','GC','CG']):
                continue

        # define bool for flag passfail status
        flag_pass = True

        # if defined, skip entry that has flag that must be absent
        for flag in flags_require_absent:
            if flag in keyvals.keys():
                flag_pass = False

        # if defined, skip entry missing a flag that must be present
        for flag in flags_require_present:
            if flag not in keyvals.keys():
                flag_pass = False

        # if flag requirements not met then skip
        if flag_pass == False:
            continue

        # if allele freq min or max defined, subset on it
        if args.allele_freq_min != None or args.allele_freq_max != None:
            try:
                allele_freq = float(keyvals[args.allele_freq_info_key])
            except:
                print("Cannot convert allele freq " + \
                      "'"+keyvals[args.allele_freq_info_key]+"' " + \
                      "to float.")
                sys.exit(1)
            if args.allele_freq_min != None:
                if allele_freq < args.allele_freq_min:
                    continue
            if args.allele_freq_max != None:
                if allele_freq > args.allele_freq_max:
                    continue

        # since snpid stored as '.' in g1k phase3 VCF, store as 
        # 'chr-pos-ref-alt'
        if args.keep_original_snpid == False:
            snpid = "-".join([chrom, pos, ref, alt])

        # if snp not filtered out, store rsid
        snpids_keep.append(snpid)

    # close filehandle to input vcf
    in_fh.close()

    # open filehandle to output text file
    if args.out_list.find(".gz") != -1:
        out_fh = gzip.open(args.out_list, "wb")
    else:
        out_fh = open(args.out_list, "w")

    # write list of snpids to output list file
    for snpid in snpids_keep:
        if args.output_plink_range:
            snpid_data = snpid.split("-")
            chrom = snpid_data[0]
            pos = snpid_data[1]
            ref = snpid_data[2]
            alt = snpid_data[3]
            start = pos
            end = str(int(pos) + len(ref) - 1)
            line = "\t".join([chrom, start, end, snpid])
        else:
            line = snpid
        out_fh.write(line + "\n")

    # close output filehandle
    out_fh.close()

    return

if __name__ == "__main__":
    main()
