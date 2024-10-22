
# Help

**Table of contents**

[1. Input](#input)<br>
[2. Options](#options)<br>
[3. Action buttons](#actions)<br>
[4. Results](#results)<br>
[5. HTTP GET](#httpget)<br>

---

## 1. Input <a name="input"></a>

The input is a list of taxa using one of the following identifier types:

+ **ncbi**. An NCBI taxonomy ID (or taxid). For example, 562.
Learn more at the <a href="https://www.ncbi.nlm.nih.gov/books/NBK53758/" target="_blank">NCBI site</a>.

+ **taxname**. A scientific name from the NCBI taxonomy.
For example, _Escherichia coli_.
Learn more at the <a href="https://www.ncbi.nlm.nih.gov/books/NBK53758/" target="_blank">NCBI site</a>.

+ **metaphlan**. A taxonomy name in the metaphlan format.
This format contains the full taxonomy of the taxon separated by 
`|\\w__`, where `\\w` can be one of the following: k = kingdom, 
p = phylum, c = class, o = order, f = family, g = genus, s = species,
t = strain. For example, 
k__Bacteria|p__Pseudomonadota|c__Gammaproteobacteria|o__Enterobacterales|f__Enterobacteriaceae|g__Escherichia|s__Escherichia_coli.

You can enter the list of taxa by pasting one identifier per line into the text
box. Alternatively, you may upload a text file (*.txt) containing one identifier
per line by using the "Browse..." button.

> ⚠️ All identifiers must be from the same
type. A warning will be displayed if they are not,
but the analysis will still run.

For detailed examples, please refer to the examples below the text box or
download one of the sample files provided under the "Browse..." button.

---

## 2. Options <a name="options"></a>

### BugSigDB

These options refer to the way the target signatures are obtained from the
BugSigDB database.

**Identifier type**. The selection must match the format used in the input
list of signatures.

**Taxonomic rank(s)**. Only taxa of the checked taxonomic ranks will be
included in the BugSigDB signatures. Use the "De(select) all" box to
quickly un(check) all of the taxonomic ranks. Use this option in combination
with "**Exact taxonomic level**" (described below).

Let’s use the signature [bsdb:1\/2\/1](https://bugsigdb.org/Study_1) as an
example. This signature contains only two elements manually annotated in
BugSigDB: Anaerostipes (genus) and Lacticaseibacillus zeae (species). The
following examples assume that "Exact taxonomic rank" has been set to "Yes".

If "genus" is checked, only Anaerostipes will be included.<br>
If "species" is checked, only _Lacticaseibacillus zeae_ will be included.<br>
If both "genus" and "species" are checked, both elements will be included.<br>
If "mixed" is checked, both elements will be included, and nothing else,
as no other taxa were manually annotated for this signature.

**Exact taxonomic level**. If "Yes" is selected, only manually curated taxa in
BugSigDB will be considered. This is the default value and the resulting
BugSigDB signatures will be created as described above.
If "No" is selected, the taxonomic tree will be
truncated at the specified rank (selected above), allowing the inclusion of a
parent taxon of the manually annotated taxa in the signature, even if the 
parent was not manually annotated. The "No" option can only be used when a single
taxonomic rank is selected.

Continuing with the [bsdb:1\/2\/1](https://bugsigdb.org/Study_1) signature as an
example:

If "genus" is selected and the exact taxonomic rank is **not** used,
the signature will include *Anaerostipes* (manually curated) and
*Lacticaseibacillus* (not manually curated),
which is the genus parent of *Lacticaseibacillus zeae* (manually curated).

> ⚠️ When "No" is selected, the taxonomic tree is truncated, allowing the
annotation of a taxon to be extended to its parent. However, this process
does not follow a formal propagation algorithm.
The tree could be truncated at the "kingdom" level, resulting in a signature
that includes the Bacteria domain.
This is unlikely to be very informative in most cases.

**Minimum size**. Filter the target BugSigDB signatures based on their
number of elements. The default is 1, meaning that only signatures with at
least one taxon identifier fulfilling all of the options above will be included
in the analysis.

---

## 3. Action buttons <a name="actions"></a>

+ Click on the "Analyze" button when the input and signature options are ready.
+ After the analysis has been run, the "Download result" button will become
available for downloading the result table in a text file with tab separated
values (.tsv extension).
+ Use the "Reset app" button to restart the app. This is equivalent to 
refreshing the webpage.

---

## 4. Results <a name="results"></a>

The results table includes:
<!-- 
<style>
  table {
    width: 100%;
    border: 1px solid #999999;
    border-collapse: collapse;
  }
  th, td {
    padding: 10px;
    border: 1px solid #999999;
  }
  
  @media (prefers-color-scheme: dark) {
    td {
      color: #dddddd;
    }
  }
</style>
-->

| Column | Description |
| ------ | ----------- |
| Signature | BugSigDB signature name. |
| JI | Jaccard Index. |
| OC | Overlapping coefficient.   |
| Size | Signature size |
| Study | The study number. When clicked, this will redirect to the BugSigDB study page.|

---

## 5. HTTP GET <a name="httpget"></a>

BugSigDBEnrich accepts the HTTP GET method to get input data. When an
HTTP method is used, the app will:

1. Fill in the text box area with the parameters from the URL.
2. Automatically select the identifiers type
(based on the first identifier in the list).
3. Run the analysis (BugSigDB option) with default values.

After this, users can choose different paratemeters and re-run the app using
the same input.

Click for short examples with <a href="https://shiny.sph.cuny.edu/BugSigDBEnrich/?vector=12916,469,642,111142,1283313,1663" target="_blank">ncbi</a>,
<a href="https://shiny.sph.cuny.edu/BugSigDBEnrich/?vector=Acidovorax,Acinetobacter,Aeromonas,Alishewanella,Alloprevotella,Arthrobacter" target="_blanck">taxname</a>,
and <a href="https://shiny.sph.cuny.edu/BugSigDBEnrich/?vector=k__Bacteria%7Cp__Pseudomonadota%7Cc__Betaproteobacteria%7Co__Burkholderiales%7Cf__Comamonadaceae%7Cg__Acidovorax,k__Bacteria%7Cp__Pseudomonadota%7Cc__Gammaproteobacteria%7Co__Moraxellales%7Cf__Moraxellaceae%7Cg__Acinetobacter,k__Bacteria%7Cp__Pseudomonadota%7Cc__Gammaproteobacteria%7Co__Aeromonadales%7Cf__Aeromonadaceae%7Cg__Aeromonas,k__Bacteria%7Cp__Pseudomonadota%7Cc__Gammaproteobacteria%7Co__Alteromonadales%7Cf__Alteromonadaceae%7Cg__Alishewanella,k__Bacteria%7Cp__Bacteroidota%7Cc__Bacteroidia%7Co__Bacteroidales%7Cf__Prevotellaceae%7Cg__Alloprevotella,k__Bacteria%7Cp__Actinomycetota%7Cc__Actinomycetes%7Co__Micrococcales%7Cf__Micrococcaceae%7Cg__Arthrobacter" target="_blanck">metaphlan</a>
identifiers.

> ⚠️ Too many identifiers could potentially exceed the number of characters
allowed in the URL. This could be especially the case for metaphlan names.
In such case, saving the identifiers in a text file (see the input section)
is recommended.
