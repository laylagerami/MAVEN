## Index

Welcome to the documentation for MAVEN (https://github.com/laylagerami/MAVEN).

Please use the navigation side-bar to access installation instructions, tutorials, and FAQs/Troubleshooting.

This page and the app itself are currently under construction...

#### What is MAVEN?
MAVEN, or **M**echanism of **A**ction **V**isualisation and **EN**richment, is an R Shiny app which is aimed at researchers wanting to understand the mechanism of action of a compound of interest. It requires 3 types of input from the user; a compound chemical structure, compound-induced gene expression data, and a prior knowledge network (we include the [Omnipath](https://omnipathdb.org/) [[1]](#1) network with the package).

#### How does MAVEN work?

MAVEN was written to enable those without prior bioinformatics expertise to be able to use the different tools integrated within the software. The tools are [DoRoThEA](https://github.com/saezlab/dorothea) [[2]](#2), [PROGENy](https://github.com/saezlab/progeny) [[3]](#3), [CARNIVAL](https://github.com/saezlab/CARNIVAL) [[4]](#4) and [PIDGIN](https://github.com/BenderGroup/PIDGINv4) [[5]](#5). An overview of the tools and how they are integrated together in MAVEN is displayed below.

Insert figure

Explain figure

#### What can I do with MAVEN?
MAVEN can be used to generate hypotheses for compound mechanism of action (or off-target effects/toxicity) which are both detailed and directly testable in the lab.  Please see the Tutorial to learn more.

## References
<a id="1">[1]</a> 
D Turei, T Korcsmaros and J Saez-Rodriguez  (2016). 
OmniPath: guidelines and gateway for literature-curated signaling pathway resources. 
Nature Methods 13 (12).

<a id="2">[2]</a> 
L Garcia-Alonso, C. H. Holland, M. M. Ibrahim, D Turei and J Saez-Rodriguez (2019).
Benchmark and integration of resources for the estimation of human transcription factor activities.
Genome Res 29:1363-1375.

<a id="3">[3]</a>
M Schubert, B Klinger, M Klünemann, A Sieber, F Uhlitz, S Sauer, M. J. Garnett, N Blüthgen and J Saez-Rodriguez (2018).
Perturbation-response genes reveal signaling footprints in cancer gene expression.
Nature Comms 9 (20).

<a id="4">[4]</a>
A Liu, P Trairatphisan, E Gjerga, A Didangelos, J Barratt and J Saez-Rodriguez (2019). 
From expression footprints to causal pathways: contextualizing large signaling networks with CARNIVAL.
npj Systems Biology and Applications 5 (40).

<a id="5">[5]</a>
L. H. Mervin, A. M. Afzal, G. Drakakis, R. Lewis, O. Engkvist and A. Bender (2015).
Target prediction utilising negative bioactivity data covering large chemical space.
Journal of Cheminformatics 7 (51).
