# Additional scripts for tutorials from tylerbarnum.com

Currently only one tutorial. Grad school is a lot of work!

## UBA Genomes
Supplemental scripts for a tutorial on using HMMs to search a large dataset, the 8000-geome Uncultivated Bacteria and Archaea (UBA) dataset from Parks et. al 2017. The repo includes the script uba-hmmer-pipeline.sh, which can perform the entire pipeline. Please consult the tutorial for more information.

Tutorial: https://tylerbarnum.com/2018/06/22/searching-uncultivated-bacteria-and-archaea-uba-genomes-for-important-genes/

Downloading the UBA genomes:

```bash
# Download the "readme" file, which describes available files for download 
wget https://data.ace.uq.edu.au/public/misc_downloads/uba_genomes/readme . 

# Download annotations for all UBA bacterial genomes (archaeal genomes are a separate file)
# Size: 54 Gb, Runtime: ~90 minutes
wget https://data.ace.uq.edu.au/public/misc_downloads/uba_genomes/uba_bac_prokka.tar.gz . 

# Unpack the tarball
# Size: 207 Gb, Runtime: ~90 minutes
tar -xzvf uba_bac_prokka.tar.gz

# Optional: remove unpacked tarball to save space
# rm uba_bac_prokka.tar.gz

# Before rename: 
# Single proteome: UBA999.faa
# >BNPHCMLN_00001 hypothetical protein

# Concatenate renamed proteins into one file
# Size: 6.3 Gb, Runtime: ~5-10 minutes
for GENOME in `ls bacteria/`; 
do sed "s|.*_|>${GENOME}_|" bacteria/${GENOME}/${GENOME}.faa | cat >> uba-bac-proteins.faa; 
done

# After rename:
# All proteomes: uba-bac-proteins.faa
# >UBA999_00001 hypothetical protein

# Optional: remove all other files to save space.
# WARNING: Only do this if you're CERTAIN you do not need the files
# rm -r bacteria/
```

Citation:
>Parks DH, Rinke C, Chuvochina M, Chaumeil P-A, Woodcroft BJ, Evans PN, et al. (2017). Recovery of nearly 8,000 metagenome-assembled genomes substantially expands the tree of life. Nat Microbiol 2: 1533–1542.
