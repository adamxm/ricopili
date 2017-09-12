studdir=MINV

echo $abbr $studdir
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
 
 
 
 ### For big data
 
  #This data is HUGE so it's going to be split into 5 files
 ls -d "$studdir"/qc/imputation/dasuqc1*/qc1/* > "$studdir"_dosages.list
 ls -d "$studdir"/qc/imputation/dasuqc1*/info/* > "$studdir"_info.list

 split -l 1000 -a 1 "$studdir"_dosages.list  "$studdir"_dosages.list_


 for splitnum in  {a..e}
 do
 echo "Will tar $splitnum"
  if [ splitnum == "e" ]
  then
   cat "$studdir"_dosages.list_"$splitnum" "$studdir"_info.list >  "$studdir"_doseinfo.list_"$splitnum"
  else
   cat "$studdir"_dosages.list_"$splitnum" >  "$studdir"_doseinfo.list_"$splitnum"
  fi 
  
  tar cvf "$abbr"_an_v1_oct6_2016_"$splitnum".tar -T "$studdir"_doseinfo.list_"$splitnum" 
 done

#Command, if doing one file, would be: tar cvf "$abbr"_an_v1_oct6_2016.tar "$studdir"/qc/imputation/dasuqc1*/qc1 "$studdir"/qc/imputation/dasuqc1*/info

#Imputed BG genotypes

 ls -d "$studdir"/qc/imputation/dasuqc1*/bgn/* > "$studdir"_bestguess.list
 split -l 600 -a 1 "$studdir"_bestguess.list  "$studdir"_bestguess.list_
 for splitnum in  {a..e}
 do
  echo "Will tar $splitnum"

  tar cvfz "$abbr"_bg_v1_oct6_2016_"$splitnum".tgz -T "$studdir"_bestguess.list_"$splitnum" 
 done


 
