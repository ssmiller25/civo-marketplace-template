# Civo Marketplace Template

A templated makefile and various utlities to help in building out a [Civo Kubernetes Marketplace App](https://github.com/civo/kubernetes-marketplace).  The contents of this template would be copied into a subdirectory within the kubernetes-marketplace repo as a starting point.  

Files

- README-marketplaceapp.md: An example README.md for your speicific app.
- manifest.yaml: Civo's Kubernetes Manifest describing the app
- post_install.md: Any post-installation instructions as necessary. 
- **app.yaml not included:**, as it should be generated by Makefile)
- Makefile: The main logic in building and testing the app
