Index
******


Welcome to the documentation for MAVEN (https://github.com/laylagerami/MAVEN).

Please use the navigation side-bar to access installation instructions, tutorials, and FAQs/Troubleshooting.

This page and the app itself are currently under construction...

What is MAVEN?
################
MAVEN, or **M**echanism of **A**ction **V**isualisation and **EN**richment, is an R Shiny app which is aimed at researchers wanting to understand the mechanism of action of a compound of interest. It requires 3 types of input from the user; a compound chemical structure, compound-induced gene expression data, and a prior knowledge network (we include the Omnipath network with the package)[1]_.

How does MAVEN work?
########################

MAVEN was written to enable those without prior bioinformatics expertise to be able to use the different tools integrated within the software. The tools are [DoRothEA](https://github.com/saezlab/dorothea), [PROGENy](https://github.com/saezlab/progeny), [CARNIVAL](https://github.com/saezlab/carnival) and [PIDGIN](https://github.com/bendergroup/PIDGINv4). An overview of the tools and how they are integrated together in MAVEN is displayed below.

Insert figure

Explain figure

What can I do with MAVEN?
################################
MAVEN can be used to generate hypotheses for compound mechanism of action (or off-target effects/toxicity) which are both detailed and directly testable in the lab.  Please see the Tutorial to learn more.


References
----------

.. [1] |test|

.. |test| replace:: Aniceto, N, et al. A novel applicability domain technique for mapping predictive reliability across the chemical space of a QSAR: Reliability-density neighbourhood. *J. Cheminform.* **8**: 69 (2016). |aniceto_doi|
.. |aniceto_doi| image:: https://img.shields.io/badge/doi-10.1186%2Fs13321--016--0182--y-blue.svg
    :target: https://doi.org/10.1186/s13321-016-0182-y
