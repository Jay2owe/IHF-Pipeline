# IHF-Pipeline
## Overview
The pipeline leverages ImageJ and Python to streamline the process from image acquisition to data analysis for immunofluorescence. The pipeline facilitates the semi-automated production of high-quality figures and 3D renders, as well as extraction of 3D and spatial data, which can also be analysed using the Jupyter notebook also part of the pipeline.
## Quick Step-by-step breakdown
<a href="#saving-confocal-images" style="color: black; text-decoration: none;text-decoration-style: dotted;">-	Save all of your Confocal Images in the correct format (AnimalID_Hemisphere_BrainRegion)</a>\
<a href="#folder-set-up">-	Keep your .lif in a separate folder on it’s own</a>\
<a href="#installing-plugins">-	Install all the required ImageJ Plugins (3D Object Counter, ImageJ 3D Suite, 3D Viewer, 3D Script)</a>\
<a href="#create-.bin-folder">-	Use the ‘Create .bin Folder’ ImageJ Macro. Make sure you have an idea of the threshold and filters needed for each channel</a>\
<a href="#draw-rois">-	Use the ‘Draw and save ROIs’ ImageJ Macro to save all the ROIs for each image</a>\
<a href="#split-and-merge-channels">-	Use the ‘Split and Merge Images’, ‘Total Integrated Density’, and ‘3D Object Analysis’ ImageJ Macros to produce the ‘Images’ folder, ‘Image Analysis’, and ‘Data Analysis’ folder and excel file, respectively</a>\
<a href="#image-tiler">-	Feed the ‘Images’ folder into the ‘Image Tiler’ Python Scripts, and the ‘Data Analysis’ folder into the ‘Save CSVs’ VBScript to produce the tiled images in PowerPoint, and CSVs for the Jupyter Notebook, respectively</a>\
<a href="#importing-the-data-and-creating-new-experiments">-	Create new Experiment objects and/or Batch objects using the new CSVs and execute the subsequent code blocks to produce figures and analyse data</a>\
<a href="#imagej-visualisation">-	Using the 3D Object stacks within the ‘Image Analysis’ folder, or any other image stacks, create 3D renders and animations using 3D Viewer, 3D Script, and the provided example codes, to enhance visualisation and add evidence to data analysis</a>\
## Saving Confocal Images
For ImageJ macros to work properly, it’s important that each image title is formatted correctly. The formatting should be ‘AnimalID_Hemisphere_BrainRegion’ as seen in Figure 1. It’s easiest to do this while taking your confocal images to prevent having to change all the names again later on. The hemisphere must be either ‘LH’ or ‘RH’ and the brain region can be anything. If there are 2 images from the same animal, hemisphere, and brain region, add a number at the end of the image name. An example name would be ‘mouse3_LH_SCN2’.
![Figure 1](https://github.com/user-attachments/assets/66948c39-4864-4350-b0de-32c5ae5dc395)
## Installing Plugins
The ImageJ macros rely on several plugins. The steps needed to install all the plugins required for the pipeline are described in Figure 2. 
![Figure 2](https://github.com/user-attachments/assets/c165e400-7bbe-4a76-a582-03a63160933e)
## Initial Steps in ImageJ
A few simple setup steps are required prior to use of ImageJ macros to provide the macros with the information they need to run smoothly and improve the flow of the pipeline overall.
### Folder Set up
With your new .lif file from the confocal, create a new folder with just the file inside (see Figure 3). 
![Figure 3](https://github.com/user-attachments/assets/d274aef8-27fb-4212-b037-4d4adfae144b)
### Create .bin Folder
The first step within ImageJ once your folder is set up is to use the create .bin folder macro. This macro will create a folder with all the relevant information about your experiment to improve the speed of inputs to the other macros, including the series of filters and threshold to use for each channel, their ideal representative colors, and the ideal display order in a representative figure. See Figure 4 for a full rundown of the macro. 
TB: Before running the macro you will need to have an idea of specific filters and threshold that will be best for extracting the true signal from each antibody channel. 
TB2: It’s often better to use an algorithm to determine the best threshold for channels such as DAPI or fluorescent proteins, given the inter-sample variability, so this option is also provided in the macro. 
![Figure 4](https://github.com/user-attachments/assets/69d89b7f-6cfe-4763-90f0-b67cea039f60)
### Draw ROIs
Once you have your folders set up, the next step is to outline and save all of your ROIs for each sample for region-specific analysis, using the Draw ROIs macro. This will create a zip file containing all of your ROIs, as well as the ROIs of images cropped to just the dimensions of your ROIs which are important in creating representative images within Python. See Figure 6 for a full rundown of the macro.
TB: There is also an option to add additional ROIs should you add to your .lif at a later date, so don’t be concerned about needing to redraw all of the ROIs if you haven’t completely finished imaging all of your samples. 
![Figure 5](https://github.com/user-attachments/assets/a8d4c0ca-8e3c-4647-9687-dd0c853308bc)
## ImageJ Macros
Once you have completed your initial steps in ImageJ, macros can be run with minimal input.
### Split and Merge Channels
This macro will separate and save each channel, in a multi-channel image stack, separately as an RGB PNG within a folder called ‘Images’ in your main directory. Images from different animals are saved into separate sub-folders, labelled according to the order the image channels should be in a representative image. The macro also has customisability in enhancing visuals or adding automatic labels and scalebars to images. See Figure 6 for a full rundown.
Once the macro is completed, you can feed the ‘Images’ folder into the ‘Image Tiler’ and ‘Image Tiler for Figures’ Python scripts (See ‘Python and VBScript Macros’ section below).
![Figure 6](https://github.com/user-attachments/assets/f0ec48d7-25e2-4e82-b5d1-ef757b4c8fde)
### Total Integrated Density
This macro is used to perform an analysis of the total integrated density of each channel for each image stack in your .lif file. This is the most standard way to compare the intensity of staining between conditions when using immunohistofluorescence. It will take a measurement of the total integrated density for each Z-stack for each channel, which can later be summed or meaned. The macro will create a new folder (‘Data Analysis’) containing an excel sheet called ‘Data Analysis’. Within the excel file, the data from each channel will be saved within a separate sheet. Once the macro is completed, you can feed the excel sheet into the ‘Save CSVs’ VBScript Macro (See ‘Python and VBScript Macros’ section below) which will automatically save each sheet as a separate CSV. It’s also useful to wait until you perform all desired analysis before doing this as all data is saved within the same excel, thus saving the need to repeat the process of saving the CSVs.
TB: There are also a number of customisation options for this macro, including whether or not only the ROI or the entire image is analysed, as well as whether any filters or binarization is applied. 
![Figure 7](https://github.com/user-attachments/assets/2739306c-97fb-472a-94ad-35cd55a9f91d)
### 3D Object Analysis
This macro is the heart and soul of the pipeline. In the macro, 3D ROIs are obtained from fluorescent particles in image stacks, for each image channel in the .lif file, which 3D and spatial data can be extracted from. Filters are applied to improve the outcome of automatic thresholding and ROI outlines. Measurements taken from 3D ROIs are redirected to unfiltered image stacks to preserve the originally captured information. This provides the volume, integrated density, mean integrated density, number of voxels, and 3D coordinates, and % of co-occurring pixels with other fluorescent particles, for each fluorescent particle, allowing in-depth analysis to be conducted within Python. The 3D ROIs are also saved within the ‘Image Analysis’ folder with separate sub-folders for each individual animal; these can be checked to ensure accurate information extraction, or can be used to easily create 3D models of individual proteins/particles, or the entire environment (See ‘Image Visualisation’ below). Data for each particle is also saved within the ‘Data Analysis’ excel file in separate sheets for each channel. 
![Figure 8](https://github.com/user-attachments/assets/b3617c39-beff-455e-9ac7-4f24370837ce)
## ImageJ Visualisation
If you have already executed the 3D Object Analysis macro, using these plugins to visualise the staining will be much easier.
### 3D Viewer
This is the more straightforward of the 2 plugins. All that is required is a 3D objects image stack (See ‘Extras’ to see how to make this outside of the macros). This plugin allows the binary objects to be imported to a 3D environment where some basic changes to colour and transparency can be made, and some basic 3D single-axis rotation animations can be performed and recorded. 
![Figure 9](https://github.com/user-attachments/assets/4f2a1ac7-6b15-4b44-84cf-ebe7b7855653)
### 3D Script
This plugin is initially more straightforward in creating the 3D model environment, but 3D animations need to be scripted, and much more complex animations can be executed, which can increase complexity compared to 3D Viewer. Any image stack can be used for this plugin, including the raw image stack, a filtered stack, or the 3D object image stack. Once imported into the environment, the intensities and light algorithms can be altered, providing much more customisability in the look of the model. To create a video, the movement of the 3D render needs to be scripted using the 3D Script custom-built language. The languages’ syntax is very easy to understand, and complex coding knowledge is not required. Some example scripts are provided in the ‘3D Scripts’ folder. 
![Figure 10](https://github.com/user-attachments/assets/76d1f3d9-8935-45e9-9fcd-3e6e41bfde3f)
## Python and VBScript Macros
These macros are outside of ImageJ and the Jupyter notebook, and are to help streamline the pipeline as a whole, and speed up parts of image analysis that are monotonous and repetitive.
### Save CSVs
This macro is made using VBScript. It will take a It will prompt you to provide a directory, then will search for an excel file named ‘Data Analysis’, delete the top row from each sheet, and save each sheet as a separate CSV file. This makes it much easier and faster to provide and format the data needed for the Jupyter notebook.
### Image Tiler
This macro is a Python script that takes a folder of images and aligns all of them side-by-side within a PowerPoint Presentation, with a new line for each subfolder. 
Using the ‘Images’ folder created from using the ‘Split and Merge Images’ ImageJ Macro, this will create a Presentation with a new line for each animal. This makes it much easier to look for patterns in the data, or to look for representative images for figures.
### Image Tiler for Figures
This macro works very similarly to ‘Image Tiler’ creating a PowerPoint Presentation of side-by-side images with separate lines for each subfolder. However, it will make the images larger (for better quality) and add labels and scalebars to the images based on the names of the subfolders and files. These tiles can then be saved as an image by selecting all the elements in PowerPoint and used within a figure. The PowerPoint will also be saved, which allows the user to easily revisit the PowerPoint and make modifications to the figure, without having to redo everything. 
![Figure 11](https://github.com/user-attachments/assets/f27df54d-dcfb-4e9e-8fac-a47666b19e14)
## Using the Jupyter Notebook
Once you have executed the desired analytical macros within ImageJ and saved each excel sheet into separate CSVs, this data can be fed into the Jupyter notebook to create Pandas DataFrames. The notebook is set up to clean the data in a way that provides maximum usability, and allows each code block to be easily customised with simple changes made by the user, allowing less experienced coders to still be able to fully harness the benefits of the notebook.
### Importing the data and creating new experiments
Only 4 main points of input are needed by the user to fully harness the benefits of the Notebook. This includes, inputting the names of the CSVs and address of the folder that contains them, then the user will need to use the ‘Create_new_experiment’ function to create an experiment object, which ties all the CSVs together. Then the ‘Create_batch’ function can be used which allows multiple experiments, using the same animals, to be tied together within a single object, and then the user needs to execute all of the required code to fully clean the data by following the new Batch object with ‘.process_data()’. This method executes a large block of code with many different functions, leading to the creation of a Batch object of Experiment objects, each tied to several Antibody and Attribute objects, which can be used within the other blocks of code to perform analysis.
![Figure 12](https://github.com/user-attachments/assets/fa746852-e34a-499d-8f10-c948a6af38da)
### Using the notebook to produce figures
Each subsequent coding cell following the creation of new experiments will produce figures and results for a different type of analysis. All that is required of the user is changes to the desired Batch or Experiment to generate data from, as well as a few parameter changes, which may or may not be needed/desired.
![Figure 13](https://github.com/user-attachments/assets/750156a7-804f-4c1a-84db-fbeab37ee9d4)
## Extras
### Other ImageJ Macros
**Orientate Left/Right Hemisphere** – These macros apply the appropriate transformations so that the image stack is represented as a left hemisphere\
**Max/Average Projection** – These macros will create a maximum or average projection of an image stack\
**Close All** – Closes all windows that can be closed with a macro\
**Split Channels** – Splits all the channels of an image stack\
**Add labels** – Adds labels and scalebars to the selected image with sizes based on user input\
**Create Inset Zooms** – Takes a series of ROIs of a particular image and saves a cropped image of each ROI for each image within an image stack. The user will also be prompted whether they want to add scalebars or labels\
	
