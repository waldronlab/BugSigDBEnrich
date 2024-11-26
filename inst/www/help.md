# BugSigDBEnrich Help

**Links**

+ [BugSigDBEnrich app](https://shiny.sph.cuny.edu/BugSigDBEnrich/)
+ [Source code](https://github.com/waldronlab/BugSigDBEnrich)
+ [Bugs report](https://github.com/waldronlab/BugSigDBEnrich/issues)

**Contents** <a name="top"></a>

+ [Introduction](#intro)<br>
+ [Input](#input)<br>
+ [Database options](#dboptions)<br>
    * [BugSigDB options](#bsdboptions)<br>
    * [Bugphyzz options](#bugphyzzoptions)<br>
+ [Analysis options](#analysisoptions)<br>
+ [Action buttons](#actions)<br>
+ [Results](#results)<br>
+ [HTTP GET](#httpget)<br>

## Introduction <a name="intro"></a>

## Input <a name="input"></a>

The app's input is a list of taxon identifiers that can be entered into
the text box, one identifier per line (**Figure 1-1**).

Alternatively, a text file (*.txt) with identifiers can be uploaded with the
`Browse` button, one identifier per line (**Figure 1-2**).

The accepted indentifiers can be of three types:

+ **ncbi**. An NCBI taxonomy ID (or taxid). For example, 562.
Learn more at the <a href="https://www.ncbi.nlm.nih.gov/books/NBK53758/" target="_blank">NCBI site</a>.<br>
+ **taxname**. A scientific name from the NCBI taxonomy.
For example, _Escherichia coli_.
Learn more at the <a href="https://www.ncbi.nlm.nih.gov/books/NBK53758/" target="_blank">NCBI site</a>.<br>
+ **metaphlan**. A taxonomy name in the metaphlan format.
This format contains the full taxonomy of the taxon separated by 
`|\\w__`, which can be one of the following: k = kingdom, 
p = phylum, c = class, o = order, f = family, g = genus, s = species,
t = strain. For example, 
`k__Bacteria|p__Pseudomonadota|c__Gammaproteobacteria|o__Enterobacterales|f__Enterobacteriaceae|g__Escherichia|s__Escherichia_coli`.<br>

> ❌ All identifiers must be of the same type.

For detailed examples, click on the links below the input box to
fill the input box (**Figure 1-3**) or click on the links below the `Browse` button to download
an example file to your machine (**Figure 1-4**).

![Input](input.png "Input")

[Back to the top](#top) ⬆️

**Figure 1**. Input.

## Database options <a name="dboptions"></a>

BugSigDBEnrich implements the [bugsigdbr](https://github.com/waldronlab/bugsigdbr)
and [bugphyzz](https://github.com/waldronlab/bugphyzz) packages to
obtain bug signatures, each with their own options.

[Back to the top](#top) ⬆️

### BugSigDB <a name="bsdboptions"></a>

**Identifier type**. BugSigDB signatures will be created with the chosen type
of identifier. The selected identifier type must match the input type
(**Figure 2-1**).

**Taxonomic rank(s)**. This option selects the taxonomic ranks allowed in
the BugSigDB signatures. The `(De)select all` checkbox can help to quickly
check/uncheck all ranks (**Figure 2-2**). 

**Exact taxonomic level**. If `Yes` is selected, the BugSigDB signatures will
only contain taxa of the selected ranks (above) that were manually curated in
the database. The `No` option, which can only be used with a single taxonomic
rank, will cut the taxonomic tree to the checked rank (above). This allows
the inclusion of parent taxa in the signatures, even if they were not manually
curated in BugSigDB (**Figure 2-3**).

Let’s use the signature [bsdb:1\/2\/1](https://bugsigdb.org/Study_1/Experiment_2/Signature_1)
as an example. This signature contains only two elements manually curated in
BugSigDB: _Anaerostipes_ (genus) and _Lacticaseibacillus zeae_ (species).

"Exact taxonomic rank" set to "Yes":

+ If "genus" is checked, only _Anaerostipes_ will be included.<br>
+ If "species" is checked, only _Lacticaseibacillus zeae_ will be included.<br>
+ If both "genus" and "species" are checked, both _Anaerostipes_ and
_Lacticaseibacillus zeae_ will be included.<br>
+ If "mixed" is checked, both elements will be included, and nothing else,
as no other taxa were manually annotated for this signature.

"Exact taxonomic rank" set to "No":

* If "genus" is checked, the signature will include *Anaerostipes*
(manually curated) and *Lacticaseibacillus* (not manually curated),
which is the parent genus of *Lacticaseibacillus zeae* (manually curated).

> ⚠️ When "No" is selected, the taxonomic tree is truncated, allowing the
annotation of a taxon to be extended to its parent. However, this process
does not follow a formal propagation algorithm.
The tree could be truncated at the "kingdom" level, resulting in a signature
that only includes the Bacteria domain, which might not be very informative.

**Minimum size**. Filter the target BugSigDB signatures based on their
number of elements. The default is 5, meaning that only signatures with at
least five taxon identifiers fulfilling all of the options above will be
included in the analysis (**Figure 2-4**).

![bugsigdb options](bugsigdb_options.png)

**Figure 2.** BugSigDB options.

[Back to the top](#top) ⬆️

 ### Bugphyzz <a name="bugphyzzoptions"></a>

![](bugphyzz_options.png)

**Figure 3**. Bugphyz options.

[Back to the top](#top) ⬆️

## Analysis options <a name="analysisoptions"></a>

You can opt to include a semantic similarity analysis in your results
(see the "Results" section below). This will load the NCBI taxonomy ontology
and run a semantic similarity analysis. This could take
several minutes, but after the first run the database will still be loaded,
reducing the time of subsequent runs (as long the page is not refreshed or 
the "Reset app" button is not clicked.)

![](analysis_options.png)

**Figure 4**. Analysis options.

[Back to the top](#top) ⬆️

## Action buttons <a name="actions"></a>

+ **Analyze**. Click on the "Analyze" button when the input and signature options are ready.
+ **Download results**. After the analysis has been run, the "Download result" button will become
available for downloading the result table in a text file with tab separated
values (.tsv extension).
+ **Reset app**. Use the "Reset app" button to restart the app. This is equivalent to 
refreshing the webpage.

[Back to the top](#top) ⬆️

## Results <a name="results"></a>

| Column | Description | Database |
| ------ | ----------- | -------- |
| Signature | BugSigDB signature name. | BugSigDB, Bugphyzz |
| JI | Jaccard Index. | BugSigDB, Bugphyzz |
| OC | Overlapping coefficient. | BugSigDB, Bugphyzz |
| OCPer | Percentile of OCs based on BugSigDB signatures. | BugSigDB, Bugphyzz |
| Size | Signature size. | BugSigDB, Bugphyzz|
| Study | The study number. When clicked, this will redirect to the BugSigDB study page. | BugSigDB |
| SigLink | Signaure ID. When clicked, this will redirect to the BugSigDB signature page. | BugSigDB |
| SemSim | Semantic similarity. | BugSigDB, Bugphyzz |

The percentile (OCper) was determined by running an all-vs-all overlapping
coefficient (OC) analysis of all BugSigDB signatures with a minimum size of 5.

![](per_plot.png)

**Figure 5**. Counts of overlapping coefficient (OC) values per percentile.

[Back to the top](#top) ⬆️

## HTTP GET <a name="httpget"></a>

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
is recommended or pasting directly in the text box.

[Back to the top](#top) ⬆️
