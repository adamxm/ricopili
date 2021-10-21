###Ricopili Modified for Ancestry (MANC) master script
#V3K - Mar 28, 2017 - Sex specific analyses
#V3j - Feb 17, 2017 - Remove need for running the preimp_dir script twice
#v3i - Jan 26, 2017 - Added archival script
#V3h - Jul 06, 2016 - Association anaylsis phenotype now directly specified to prevent error
#V3g - Jun 20, 2016 - pcs are no longer based on projection
#V3f - Jun 17, 2016 - Ancestry .predpc files now exported with header
#V3e - Jun 15, 2016 - Analyst initials and disease name no longer hard coded
#V3d - Jun 15, 2016 - Include PCA and analysis steps
#V3c - Jun 7,  2016 - Updated annotations to be more clear. List of subjects of each ancestry after QC was not done corrected (showed pre-qc N)
#V3b - Jun 6,  2016 - Made some variable paths correct, changed location of IBD step
#V2  - May 18, 2016 - Removed 'failed' SNP filters
#V1  - May 16, 2016 - Initial release

#This file contains step by step commands for how to run Ricopili MANC
#It is essentially the same as what you would do for Ricopili, but with some
#additional commands involved. Follow the Ricopili installation instructions
#then use this guide to QC and impute the data

#All commands are meant to be run from a Linux shell. The user will have to 
#download some files and note where they are stored

#This is currently only set up for LISA 
#(or, given additional configurations, a computing system with TORQUE on it)

###Initial configuration steps

 module load R

##Path to working directory (Folder must exist. You the user must make this folder!) where you would like all data to be analyzed and stored
 WORKING_DIR=/home/maihofer/daniel/mamh
 
##call into it
 cd $WORKING_DIR

##Make a folder called starting_data and put your PLINK genotypes into it!
 mkdir starting_data
 
##Make a folder for the ancestry call data and temporary files directories
 mkdir ancestry
 mkdir temporary_files

##Make a folder called scripts and put the following scripts into it: call_ancestry_v2_may6_2016.sh, ancestry_plots_v1_may5_2016.R, make_rsid_update_file_v1_may5_2016.R, rsidupdate_for_impdir_v1_may5_2016.R, make_hwe_file_v1_may5_2016.R
 mkdir scripts
 
 
##Specify the locations of the other input files.

#Give the location of the PLINK 2 binary
 plink_location=/home/maihofer/ricopili/plink2beta335/plink

#Write the name of the PLINK bed/bim/fam 
 bfile=PGC_NIMH_Cruz_PTSD_GSA_PGC_NIMH_Cruz_PTSD_GSA_ids

#Give the folder where this PLINK binary is stored 
 bfile_directory="$WORKING_DIR"/starting_data

#Location of the list of ancestry panel SNP rsids
 snpweights_snplist=/home/maihofer/ricopili/SNPweights2.1/hgdp_kgp_merged_v3_jointsample_v4_k6.snplist
 
#Location of ancestry panel
 snpweightfile_path=/home/maihofer/ricopili/SNPweights2.1/hgdp_kgp_merged_gsa_v3_jointsample_v4_k6.snpweightrefpanel
 
#Location of ancestry panel cluster centers
snpweight_clustercenters=/home/maihofer/ricopili/SNPweights2.1/hgdp_kgp_merged_gsa_v3_jointsample_v4_k6_forsnpweights.snpweightrefpanel_clustercenters.csv

#Location of SNPweights (see http://www.hsph.harvard.edu/alkes-price/software/)
 snpweights_path=/home/maihofer/ricopili/SNPweights2.1/inferancestry.py
 
 
#Location of convertf tool from EIGENSOFT (http://www.hsph.harvard.edu/alkes-price/software/)
conda deactivate
module load 2020
module load EIGENSOFT/7.2.1-foss-2020a
 eigensoft_loc=convertf

#abbreviation (exactly 4 characters) for the study name
 abbr=mamh
#Enter disease name (3 characters) for the disease studied
 dis=pts
#Enter analyst initials (initials that you specified when you installed ricopili using ./rp_config
 an=am

#Give path of Illumina SNP ID to rs-id conversion table. Illumina provides these in the 
#Go to the kit support page for the array, click downloads, then click ArrayNameHere support files
#the file should be under the name of "ArrayNameHere Loci Name to rsID Conversion File"
 illumina_snplist=starting_data/GSA-24v2-0_A1_b150_rsids.txt

#Phenotype file (optional, do if you need to update your PLINK file) in the 3 column, tab delimited format of FID IID Phenotype (1 = control, 2 = case, -9 = missing)
 phenotype_filepath=starting_data/cruz_ptsd.pheno
#Gender file (optional, do if you need to update your PLINK file) in the 3 column, tab delimited format of FID IID Gender (1 = male, 2 = female)
 gender_filepath=starting_data/cruz_ptsd.gender
 
###Ancestry determination steps

#Execute from base directory with folder 
cd $WORKING_DIR


#starting_data that has the initial genotype data, Illumina marker annotations, phenotype and gender information

#Use Illumina supplied list of SNPs that can be renamed
 Rscript --vanilla scripts/make_rsid_update_file_v1_may5_2016.R "$illumina_snplist"

 rsidfile="$WORKING_DIR"/"$illumina_snplist"_nodot_first

## Call subject ancestries. 
 chmod u+rwx scripts/call_ancestry_v2_may6_2016.sh
 scripts/call_ancestry_v2_may6_2016.sh $plink_location $bfile $rsidfile $bfile_directory $snpweights_snplist $snpweights_path $snpweightfile_path $eigensoft_loc

#Combine the SNPweights ancestry calls
 cat temporary_files/"$bfile"_anc_*.predpc_oneweek  > ancestry/"$bfile".predpc_oneweek

#Call into the ancestry folder, classify subject ancestry, produce an ancestry PC plot
 cd "$WORKING_DIR"/ancestry 
 Rscript --vanilla "$WORKING_DIR"/scripts/ancestry_plots_v4_mar1_2017.R "$bfile".predpc_oneweek "$snpweight_clustercenters"

### Preimputation QC

#call back into base dir
cd "$WORKING_DIR"

 #just in case phenotypes/ids and sex stuff need modification..
 $plink_location --bfile "$bfile_directory"/"$bfile" --make-bed --out "$abbr"  --update-sex "$gender_filepath" --pheno "$phenotype_filepath" 
 
 
 
#Guess the platform of the data
 echo "Platform guess"
 plague_2 "$abbr" > "$abbr".plague

#Write the platform name to a text file
 Rscript scripts/plaguematch_v1.R "$abbr".plague

#Assign the name to a variable
 platform=$(awk '{print $1}' "$abbr".plague.platform)

#Create a new family ID file with updated names (according to disease status/study name/ancestry/analyst/platform)
 echo "Creating subject names"
 id_tager_2 --create --nn "$dis"_"$abbr"_"mix"_"$an"_"$platform"  --cn "$dis"_"$abbr"_"mix"_"$an" "$abbr".fam


#Now I have the IDs that will be used. Make file for PLINK of IDs to keep using this, the ancestry determination, and IBD info.

#Run IBD to get a list of related subjects to remove
 $plink_location --bfile "$bfile_directory"/"$bfile" --maf 0.05 --geno 0.02 --mind 0.02 --indep-pairwise 50 5 0.2 --out temporary_files/"$bfile"_ibd
 $plink_location --bfile "$bfile_directory"/"$bfile" --mind 0.02 --extract  temporary_files/"$bfile"_ibd.prune.in --genome --min 0.4 --out  temporary_files/"$bfile"_ibd
 awk '{if(NR ==1) print "FID","IID"; else print $3,$4}' temporary_files/"$bfile"_ibd.genome > temporary_files/"$bfile"_ibd.remove

#To the user: Examine the ancestry files (i.e. in the ancestry folder, the file with suffix _ancestries_samplesizes.txt) 
#and find the largest homogenous ancestry group. If N < 200, take largest two-way admixed group.
#This list of subjects will be used for certain QC steps and strand alignment steps!!

#Write down the population name here. Can be one of either: 
#eur (european), csa (central-south asian), eas (east asian), aam (African American), 
#lat (latino), nat (Native American/Alaska Native), pue (Puerto Rican -like), oce (Oceanian), fil (filipino -like)
 pop="nat"
 
#This script will take your designated population and filter out related subjects #
 Rscript --vanilla scripts/make_hwe_file_v1_may5_2016.R  qc/"$dis"_"$abbr"_mix_"$an".fam ancestry/"$bfile".predpc_oneweek_ancestries.txt "$pop" temporary_files/"$bfile"_ibd.remove
 
#Make sure the file listing unrelateds of a given ancestry actually exists (If this returns an error instead of giving you a file header, something has gone wrong)
 head "$WORKING_DIR"/ancestry/"$bfile".predpc_oneweek_ancestries.txt_"$pop".subjects

 #all of the action starts here.
#preimp_dir --dis pts --pop mix --out psy1f

#I should edit this to just skip the plague and idtager steps.
preimp_dir.manc --dis pts --pop mix --keep "$WORKING_DIR"/ancestry/"$bfile".predpc_oneweek_ancestries.txt_"$pop".subjects --out mamhqc



#User: Check the QC report that the pre-imputation step generated, make sure it's acceptable before proceeding to imputation

#For samples that passed QC, list all subjects within a given ancestry group 

 Rscript --vanilla scripts/make_ancestries_files_v2_may20_2016.R qc/"$dis"_"$abbr"_mix_"$an"-qc1.fam ancestry/"$bfile".predpc_oneweek_ancestries.txt  


#Call to the directory where imputation will be done
 cd "$WORKING_DIR"/qc/imputation

##Update loci name to rs-id, then check for redundant  rsids, then pull the redundant ones based on missingness

#Make a directory where updated missingness info and allele name updates will go
 mkdir id_updates

#Get missingness per marker
 $plink_location --bfile "$WORKING_DIR"/qc/"$dis"_"$abbr"_mix_"$an"-qc1 --missing --out id_updates/"$dis"_"$abbr"_mix_"$an"-qc_tmp1

#Make rs-id name update file 
 Rscript --vanilla "$WORKING_DIR"/scripts/rsidupdate_for_impdir_v1_may5_2016.R "$WORKING_DIR"/qc/"$dis"_"$abbr"_mix_"$an"-qc1.bim id_updates/"$dis"_"$abbr"_mix_"$an"-qc_tmp1.lmiss "$WORKING_DIR"/"$illumina_snplist"_nodot_first

#update loci names to rs-ids
 $plink_location --bfile "$WORKING_DIR"/qc/"$dis"_"$abbr"_mix_"$an"-qc1  --update-name "$WORKING_DIR"/qc/"$dis"_"$abbr"_mix_"$an"-qc1.bim_allele_update --make-bed --out "$dis"_"$abbr"_mix_"$an"-qc1
#not sure that the above steps are really necessary I should do a comparison for this at some point..
 
  impute_dirsub.manc --keep "$WORKING_DIR"/ancestry/"$bfile".predpc_oneweek_ancestries.txt_"$pop".subjects --popname EUR --refdir /home/maihofer/hrc/HRC_reference.r1-1 --out mamhimpute
  
    
#Give the location of the PLINK 2 binary
 plink_location=/home/maihofer/rp_depends/plink/plink
 
 cd  $WORKING_DIR/qc
 
 mkdir impute_x
 mkdir impute_x/males
 mkdir impute_x/females
 mkdir impute_x/males/pi_sub
 mkdir impute_x/females/pi_sub
 
#Format X chromosome
for bfile2 in $(ls pts_"$abbr"_mix_am-qc1.bed | sed 's/.bed//g')
do

 $plink_location --bfile $bfile2 --chr 23 --make-bed --out impute_x/"$bfile2".chrX

 awk '$1="X"' impute_x/"$bfile2".chrX.bim > impute_x/"$bfile2".chrX.bim.tmp #I think i dont need to do this, its a waste of time, plink will change it
 rm impute_x/"$bfile2".chrX.bim
 mv impute_x/"$bfile2".chrX.bim.tmp impute_x/"$bfile2".chrX.bim

 #Note that files have the genome build in the name. I assume here that they are hg19, this may not be the case for all datasets. Check the autosome files!!

 $plink_location --bfile impute_x/"$bfile2".chrX --filter-males --make-bed --out impute_x/males/"$bfile2".chrX.mal
 $plink_location --bfile impute_x/"$bfile2".chrX --filter-females --make-bed --out impute_x/females/"$bfile2".chrX.fem
 
 $plink_location --bfile impute_x/"$bfile2".chrX --filter-males --make-bed --out impute_x/males/pi_sub/"$bfile2".chrX.mal.hg19
 $plink_location --bfile impute_x/"$bfile2".chrX --filter-females --make-bed --out impute_x/females/pi_sub/"$bfile2".chrX.fem.hg19
done
#I seem to be experiencing problems in that PLINK is renaming X to chr 23 when I make the new versions of these files! and so it is not matching the reference file
#for now I have modified the culprit file, i.e. cat genetic_map_chrX_combined_b37.chr.txt | sed 's/X/23/g' > genetic_map_chrX_combined_b37.chr.txt.23

#do imputations

#Note: You must copy over the buigue file from pi_sub file for the autosome imputations and buigue_done file from the base autosome imputation directory.
#Otherwise it will try to guess the build and fail, because that requires a whole genome

#above files are made, just need to start this step... check that all datasets have men, otherwise this wont run.. ie no gracie mle, safr maybe, dnhs maybe, wach?
pop=eur
popfile="$WORKING_DIR"/ancestry/"$bfile".predpc_oneweek_ancestries.txt_"$pop".subjects
popname=EUR
#Impute males
cd "$WORKING_DIR"/qc/impute_x/males

 #cp $WORKING_DIR/pi_sub/*.buigue pi_sub/. #rename to . chr x
 touch buigue_done
 cp "$WORKING_DIR"/qc/imputation/pi_sub/*.bim.buigue pi_sub/.
 
 impute_dirsub.manc --keep $popfile --popname $popname --refdir /home/maihofer/hrc_short/chr23 --out delbmales 

#Females

cd "$WORKING_DIR"/qc/impute_x/females

 touch buigue_done
 cp "$WORKING_DIR"/qc/imputation/pi_sub/*.bim.buigue pi_sub/.

 impute_dirsub.manc --keep $popfile --popname $popname --refdir /home/maihofer/hrc_short/chr23 --out delbfemales 

 
############ Do PCA within ancestry groups
cd "$WORKING_DIR"/qc
mkdir pca
cd pca
for popg in eur all #User: List all populations you will analyze here as a space delimited list
do
 #Subset to subjects in ancestry group to be analyzed
 keep_command=""
 if [ $popg != "all" ]
  then
   keep_command="--keep "$WORKING_DIR"/ancestry/"$bfile".predpc_oneweek_ancestries.txt_"$popg"_classifications.subjects"
  fi
 $plink_location --bfile "$WORKING_DIR"/qc/"$dis"_"$abbr"_mix_"$an"-qc $keep_command --make-bed --out "$dis"_"$abbr"_mix_"$an"-qc-"$popg"
 pcaer_20 --out "$dis"_"$abbr"_mix_"$an"-qc-"$popg"_pca  "$dis"_"$abbr"_mix_"$an"-qc-"$popg".bim --noproject
done


############ Do PCA within ancestry groups
cd "$WORKING_DIR"/qc
mkdir pca
cd pca
for popg in eur aam # all #User: List all populations you will analyze here as a space delimited list
do
 #Subset to subjects in ancestry group to be analyzed
 keep_command=""
 if [ $popg != "all" ]
  then
   keep_command="--keep "$WORKING_DIR"/ancestry/"$bfile".predpc_oneweek_ancestries.txt_"$popg"_classifications.subjects"
  fi
 $plink_location --bfile "$WORKING_DIR"/qc/"$dis"_"$abbr"_mix_"$an"-qc1 $keep_command --make-bed --out "$dis"_"$abbr"_mix_"$an"-qc-"$popg"
 pcaer --out "$dis"_"$abbr"_mix_"$an"-qc-"$popg"_pca  "$dis"_"$abbr"_mix_"$an"-qc-"$popg".bim --noproject
done


#archive onto DAC
for abbr in delb
do

mkdir $abbr
mkdir "$abbr"/cobg_dir_genome_wide/
mkdir "$abbr"/qc1
mkdir "$abbr"/info
mkdir "$abbr"/qc
mkdir "$abbr"/covariates

cp /home/maihofer/freeze3_imputation/"$abbr"/qc/imputation/cobg_dir_genome_wide/*"$abbr"* "$abbr"/cobg_dir_genome_wide/.
cp /home/maihofer/freeze3_imputation/"$abbr"/qc/impute_x/females/cobg_dir_genome_wide/*"$abbr"* "$abbr"/cobg_dir_genome_wide/.
cp /home/maihofer/freeze3_imputation/"$abbr"/qc/impute_x/males/cobg_dir_genome_wide/*"$abbr"* "$abbr"/cobg_dir_genome_wide/.

cp /home/maihofer/freeze3_imputation/"$abbr"/qc/imputation/dasuqc1_pts_"$abbr"_mix_am-qc1.hg19.ch.fl/info/* "$abbr"/info/.
cp /home/maihofer/freeze3_imputation/"$abbr"/qc/imputation/dasuqc1_pts_"$abbr"_mix_am-qc1.hg19.ch.fl/qc1/* "$abbr"/qc1/.

cp /home/maihofer/freeze3_imputation/"$abbr"/qc/impute_x/males/dasuqc1_pts_"$abbr"_mix_am-qc1.chrX.mal.hg19.ch.fl/info/* "$abbr"/info/.
cp /home/maihofer/freeze3_imputation/"$abbr"/qc/impute_x/males/dasuqc1_pts_"$abbr"_mix_am-qc1.chrX.mal.hg19.ch.fl/qc1/* "$abbr"/qc1/.

cp /home/maihofer/freeze3_imputation/"$abbr"/qc/impute_x/females/dasuqc1_pts_"$abbr"_mix_am-qc1.chrX.fem.hg19.ch.fl/info/* "$abbr"/info/. 
cp /home/maihofer/freeze3_imputation/"$abbr"/qc/impute_x/females/dasuqc1_pts_"$abbr"_mix_am-qc1.chrX.fem.hg19.ch.fl/qc1/* "$abbr"/qc1/.

cp /home/maihofer/freeze3_imputation/"$abbr"/qc/pts_"$abbr"_mix_am-qc1.* "$abbr"/qc/.
cp /home/maihofer/freeze3_imputation/"$abbr"/qc/pca/*.mds_cov "$abbr"/covariates/.
cp /home/maihofer/freeze3_imputation/"$abbr"/ancestry/*.header "$abbr"/covariates/. 
cp /home/maihofer/freeze3_imputation/"$abbr"/ancestry/*.pdf "$abbr"/covariates/. 

done


############ Do analysis

cd "$WORKING_DIR"/qc/imputation/


for popg in eur # all #List all populations you will analyze here
do
 #Make a copy of the PCA covariate
 cp "$WORKING_DIR"/qc/pca/"$dis"_"$abbr"_mix_"$an"-qc-"$popg"_pca.menv.mds_cov ./
 #Use the QCed data phenotype, because currently a bug changes the dosage data phenotype from missing to controls
 awk '{print $1,$2,$6}' "$dis"_"$abbr"_mix_"$an"-qc.fam > "$dis"_"$abbr"_mix_"$an"-qc-"$popg".pheno
 #Run analysis. User: Specify the PCA covariates you want to include (default 1,2,3,4,5)
 postimp_navi_18 --out "$abbr"_"$popg" --mds "$dis"_"$abbr"_mix_"$an"-qc-"$popg"_pca.menv.mds_cov --coco 1,2,3,4,5 --pheno "$dis"_"$abbr"_mix_"$an"-qc-"$popg".pheno --addout analysis_run2 --nocon --nohet 
 postimp_navi_18 --out "$abbr"_"$popg" --mds "$dis"_"$abbr"_mix_"$an"-qc-"$popg"_pca.menv.mds_cov --coco 1,2,3,4,5 --pheno "$dis"_"$abbr"_mix_"$an"-qc-"$popg".pheno --males --addout analysis_run2_males --nocon --nohet 
 postimp_navi_18 --out "$abbr"_"$popg" --mds "$dis"_"$abbr"_mix_"$an"-qc-"$popg"_pca.menv.mds_cov --coco 1,2,3,4,5 --pheno "$dis"_"$abbr"_mix_"$an"-qc-"$popg".pheno --females --addout analysis_run2_females --nocon --nohet 
 
done

 
############# Archive data (sample code)

studdir=MINV
#Haplotypes
 tar cvzf "$abbr"_ha_v1_oct6_2016.tgz "$studdir"/qc/imputation/pi_sub
#Imputed genotypes
 tar cvf "$abbr"_an_v1_oct6_2016.tar "$studdir"/qc/imputation/dasuqc1*/qc1 "$studdir"/qc/imputation/dasuqc1*/info
#Imputed BG genotypes
 tar cvfz "$abbr"_bg_v1_oct6_2016.tgz "$studdir"/qc/imputation/dasuqc1*/bgn
#Association analysis results
 tar cvf "$abbr"_rp_v1_oct6_2016.tar "$studdir"/qc/imputation/distribution
#Basic QC, PCA
 tar cvzf "$abbr"_qc_v1_oct6_2016.tgz "$studdir"  --exclude="$studdir"/qc/imputation/dasuqc1* --exclude="$studdir"/qc/imputation/dameta* --exclude="$studdir"/qc/imputation/daner* --exclude="$studdir"/qc/imputation/report* --exclude="$studdir"/qc/imputation/distribution --exclude="$studdir"/qc/imputation/pi_sub
#Starting data only(minimal set, redundant with qc)
 tar cvfz "$abbr"_sd_v1_oct6_2016.tgz "$studdir"/starting_data "$studdir"/scripts

 tar tvzf "$abbr"_qc_v1_oct6_2016.tgz > tar_contents/"$abbr"_qc_v1_oct6_2016.txt
 tar tvzf "$abbr"_ha_v1_oct6_2016.tgz > tar_contents/"$abbr"_ha_v1_oct6_2016.txt
 tar tvf "$abbr"_an_v1_oct6_2016.tar > tar_contents/"$abbr"_an_v1_oct6_2016.txt
 tar tvfz "$abbr"_bg_v1_oct6_2016.tgz > tar_contents/"$abbr"_bg_v1_oct6_2016.txt
 tar tvfz "$abbr"_sd_v1_oct6_2016.tgz  > tar_contents/"$abbr"_sd_v1_oct6_2016.txt
 tar tvf "$abbr"_rp_v1_oct6_2016.tar > tar_contents/"$abbr"_rp_v1_oct6_2016.txt
 
 md5sum "$abbr"_*
 
 cp "$abbr"_* /archive/maihofer/.
 md5sum /archive/maihofer/"$abbr"_*
 


