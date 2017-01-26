Ricopili MANC Version 3e 
Adam Maihofer 
amaihofer@ucsd.edu

Version History
V3I - Jan 26, 2017 - Added code to zip up final data

V3h - Jul 06, 2016 - Now use --pheno to declare phenotype in analysis step

V3g - Jun 20, 2016 - pcs are no longer based on projection

V3f - Jun 17, 2016 -  Ancestry .predpc files now given header

V3e - Jun 15, 2016 -  Analyst initials and disease name no longer hard coded

V3d - Jun 15, 2016 - Included PCA and GWAS steps in the master script

V3c - Jun 7, 2016 - Updated master script for interpretability

V3b - Jun 6, 2016 - Reference data cluster centers variable may have pointed to wrong location, now fixed

V3a - May 31, 2016 - Ancestry plots now have legend

V3 - May 20, 2016 - Now includes PCA calculation (within ancestry group)

V2a - May 19, 2016 - Added an extra script that produces a list of subjects within each ancestry group

V2 - May 18, 2016 - Removed MAF and info score quality filters for determining 'qc1' and 'qc1f' data. Removed 'bg' and 'bgs' genotype outputs. Removed parallel job modification (set to 0 after failure) setting from the imputation step of the imp_dirsub script.

V1 - May 16, 2016 - Initial release


Installation:
The user should download the ricopili files in rp_bin, then follow the instructions on
https://sites.google.com/a/broadinstitute.org/ricopili/home 
to install this version of ricopili (note: use the scripts from this github page, not from the ricopili website!)

Download all scripts in the base directory as well, and follow guidelines in manc_master_01 to run the pipeline

Addtl. notes:
The method requires some additional files that need to be downloaded:

eigensoft (last tested with version on LISA) http://www.hsph.harvard.edu/alkes-price/software/

snpweights (last tested with version 2.1) http://www.hsph.harvard.edu/alkes-price/software/

PLINK2 (last tested with beta 335) https://www.cog-genomics.org/plink2



The script is currently set up under the assumption that the user is working on LISA or a TORQUE computing cluster with similar job parameters (e.g. node or memory requirement options in the qsub parameters are the same as they are on LISA). It may run regardless,
however certain hacks made for huge samples (i.e. running 1 job at a time on an entire node) won't work.

The ancestry method contained here assumes that the user is working on a TORQUE computing cluster. I can provide a version of the scripts that does not require a cluster if there is demand for it.


