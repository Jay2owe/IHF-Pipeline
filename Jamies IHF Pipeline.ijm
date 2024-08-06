//Set global variables to be used inside macros
var colors = newArray("red", "green", "blue", "cyan", "grey", "magenta", "yellow");
var antibodyChannelNumbers = "nothing";
var antibody_channel_info = "nothing";
var Directory = "nothing";
var filelist = "nothing";
var exp_name = "nothing";
var imageNameParts = "nothing";
var animal_name = "nothing";
var hemisphere = "nothing";
var region = "nothing";
var channel_names = "your images";
var channel_numbers = "nothing";
var channel_thresholds = "nothing";
var num_channels = "nothing";
var new_threshold = "nothing";
var default_names = "nothing";
var default_colors = "nothing";
var default_numbers = "nothing";
var default_thresholds = "nothing";
var excel = "C:\\Users\\Jamie\\OneDrive - Imperial College London\\New Data.xlsx"
//var excel = "C:\\Users\\jm3923\\OneDrive - Imperial College London\\New Data.xlsx"

macro "Get ROI areas Action Tool - "{
	openFiles();
	openFilesZip();
	initialize_excel();
	run("Set Measurements...", "area redirect=None decimal=3");
	for (i=0;i<roiManager("count")/2;i++){
		roiManager("select", i*2);
		run("Measure");
		roiManager("deselect");
	}
	run("Read and Write Excel", "stack_results sheet=[ROI Areas] file_mode=queue_write");
	write_to_excel();
	closeAll();
}

macro "Get Image Labels Action Tool - "{
	openFiles();
	initialize_excel();
	images = getList("image.titles");
	Table.create("Results");
	for (i=0;i<lengthOf(images);i++){
		setResult("Labels", i, images[i]);
	}
	run("Read and Write Excel", "stack_results sheet=[Image Labels] file_mode=queue_write");
	write_to_excel();
	closeAll();
}

macro "Create bin file Action Tool - "{
	openFiles();
	image_name = getTitle();
	bin_file = Directory + "\\.bin";
	File.makeDirectory(bin_file);
	//create dialog box with all the options
	Dialog.create("Antibody Info");
	Dialog.addMessage("Separate Inputs with a Space");
	Dialog.addString("Antibody Names", "Antibody1 Antibody2 Antibody3 Antibody4", 30);
	Dialog.addString("Antibody Colors", "Color1 Color2 Color3 Color4", 30);
	Dialog.addString("Antibody Thresholds", "default default default default", 30);
	Dialog.addMessage("Custom Filter");
	Dialog.addToSameRow();
	Dialog.addCheckboxGroup(1, 4, newArray("1", "2", "3", "4"), newArray(false, false, false, false));
	// Finally show the GUI, once all parameters have been added
	Dialog.show();
	
	// ie one can recover the values in order of appearance 
	name_info  = Dialog.getString(); // Sliders are number too
	color_info = Dialog.getString();
	threshold_info  = Dialog.getString();
	num_channels  = Dialog.getChoice();
	custom_filter1 = Dialog.getCheckbox();
	custom_filter2 = Dialog.getCheckbox();
	custom_filter3 = Dialog.getCheckbox();
	custom_filter4 = Dialog.getCheckbox();
	custom_filters = newArray(custom_filter1, custom_filter2, custom_filter3, custom_filter4);
	for (c=0; c<lengthOf(custom_filters);c++){
		if (custom_filters[c] == 1) {
			selectImage(image_name);
			run("Duplicate...", "title=[C"+c+1+"] duplicate channels="+c+1);
			run("Record...");
			//Add option for doing nothing and making a guassian, subtract, median file
			waitForUser("Apply desired filters\nSave as .ijm file 'C"+c+1+"_Filters' inside .bin folder");
		} else if (custom_filters[c] == 0){
			curdir = getDirectory("imagej");
			filter_file = File.open(bin_file+"\\C"+c+1+"_Filters.ijm");
			File.copy(curdir+"\\macros\\default_filter.ijm", filter_file);
			File.close(filter_file);
		}
		close("C"+c+1);
	}
	data_file = File.open(bin_file+"\\Channel_Data.txt");
	print(data_file, name_info+"\n"+color_info+"\n"+threshold_info);
	closeAll();
}

macro "Draw and Save ROIs Action Tool - C990O505f"{
	add_to_roi = getBoolean("Add to existing ROIs?");
	openFiles();
	if (add_to_roi == true){openFilesZip();}
	initialize_excel();
	images = getList("image.titles");
	
	for (i=0;i<lengthOf(images);i++){
		selectImage(images[i]);
		getNameParts(images[i]);
		condFile = Directory + File.separator + animal_name;
   		orientate(hemisphere, images[i]);
   		draw_and_add_ROI(images[i], condFile);
	} run("Read and Write Excel", "no_count_column cell_ref=A2 file_mode=write_and_close");
	roiManager("Save", Directory + File.separator + "SCN ROIs.zip");
	closeAll();}

macro "Split and Merge Channels Action Tool - C00fF00bbC0f0F33bbCf00F66bb" {
	
	//Get user input
	var Directory = "nothing";
	get_channel_data();
	Dialog.create("Antibody Info");
	Dialog.addMessage("Separate Inputs with a Space");
	Dialog.addString("Antibody Names", default_names, 30);
 	Dialog.addString("Channel order for tiling", "1 2 3 4", 30);
	Dialog.addString("Antibody Colors", default_colors, 30);	
	Dialog.addCheckboxGroup(1, 3, newArray("Automated?", "All Merge Combinations?", "Add Labels/ScaleBars?"), newArray(false, false, false));
	// Finally show the GUI, once all parameters have been added
	Dialog.show();
	
	name_info  = Dialog.getString();
	channel_names = split(name_info, " ");
	num_of_channels = lengthOf(channel_names);
	order_info = Dialog.getString();
	channel_orders = split(order_info, " ");
	color_info = Dialog.getString();
	channel_colors = split(color_info, " ");
	automation_mode = Dialog.getCheckbox();
	allmerges = Dialog.getCheckbox();
	label_images = Dialog.getCheckbox();
	
	openFiles();
	close("*virus");
	close("*setting*");
	imageFile = Directory + File.separator + "Images";
	File.makeDirectory(imageFile);
	//Get name inputs for split and merge function
	antibodyNames = channel_names;
	antibodyChannels = channel_numbers;
	antibodyColours = channel_colors;
	antibody1_Channel_Colour = antibodyNames[0] +"_1_"+ antibodyColours[0];
	antibody2_Channel_Colour = antibodyNames[1] +"_2_"+ antibodyColours[1];
	if (num_of_channels > 2) {
	antibody3_Channel_Colour = antibodyNames[2] +"_3_"+ antibodyColours[2];}
	if (num_of_channels > 3) {
	antibody4_Channel_Colour = antibodyNames[3] +"_4_"+ antibodyColours[3];}
	
	//Iterate through each image series
	images = getList("image.titles");
	print(images[0]);
	for (i = 0; i < lengthOf(images); i++) {
		//Get condition name
		getNameParts(images[i]);
		selectImage(images[i]);
		
		//Orientate to look like left SCN
		orientate(hemisphere, images[i]);
		
		//Split colour channels, enhance, convert to RGB and create a merge of all channels
		antibodies_channels_colours = antibody1_Channel_Colour+"."+antibody2_Channel_Colour+"."+antibody3_Channel_Colour;
		if (num_of_channels > 3){
			antibodies_channels_colours = antibodies_channels_colours + "." + antibody4_Channel_Colour;}
		splitAndZ(images[i], antibodies_channels_colours, false, false, true, automation_mode, true);
	
		//Create condition save file within master file
		condFile = imageFile + File.separator + animal_name;
		File.makeDirectory(condFile);
		
		if (label_images == true){
			//Set text style
			setFont("Calibri", 1024/11, "bold antialiased");
			setJustification("left");
			setColor("white");
			
			//Add labels to each split antibody image
			h_indent = 20;
			v_indent = 60;
				//For DAPI
			selectImage(animal_name + "_" + antibodyNames[0]);
					//Add text
			Overlay.drawString(antibodyNames[0], h_indent, v_indent, 0.0);
			Overlay.show();
					//Get width of text for appropriate indent
			run("List Elements");
			antibody1_width = getResult("Width", 0);
			run("Scale Bar...", "width=50 height=100 thickness=5 font=50 location=[Lower Left] bold overlay");
			run("Clear Results");
				//For channel 4
			if (num_of_channels > 3){
				selectImage(animal_name + "_" + antibodyNames[3]);
				Overlay.drawString(antibodyNames[3], h_indent, v_indent,  0.0);
				Overlay.show();
				run("List Elements");
				antibody4_width = getResult("Width", 0);
				run("Scale Bar...", "width=50 height=100 thickness=5 font=50 location=[Lower Left] bold overlay");
				run("Clear Results");
			}
				//For channel 3
			if (num_of_channels > 2){
				selectImage(animal_name + "_" + antibodyNames[2]);
				Overlay.drawString(antibodyNames[2], h_indent, v_indent, 0.0);
				Overlay.show();
				run("Scale Bar...", "width=50 height=100 thickness=5 font=50 location=[Lower Left] bold overlay");
				run("List Elements");
				antibody3_width = getResult("Width", 0);
				run("Clear Results");
			}
				//For channel 2
			selectImage(animal_name + "_" + antibodyNames[1]);
			Overlay.drawString(antibodyNames[1], h_indent, v_indent, 0.0);
			Overlay.show();
			run("Scale Bar...", "width=50 height=100 thickness=5 font=50 location=[Lower Left] bold overlay");
			run("List Elements");
			antibody2_width = getResult("Width", 0);
			run("Clear Results");
		
		//Add coloured and appropriately spaced labels to merge for each antibody image
			selectImage("Composite");
			Overlay.drawString("Merge", h_indent, v_indent, 0.0);
			Overlay.show();
			run("Scale Bar...", "width=50 height=100 thickness=5 font=50 location=[Lower Left] bold overlay");
		}
		selectImage("Composite");
		rename("Merge_SCN");
		saveAs("PNG", condFile + File.separator + "Merge_" + hemisphere + region + ".png");
		close();
		
		if (allmerges){
			//Reset indent
			h_indent = 20;
			
			//Create each possible merge combination and add coloured and appropriately spaced labels
			widths = ""+antibody1_width+"_"+antibody2_width+"_"+antibody3_width;
			if (num_of_channels > 3){
				widths = widths+"_"+antibody4_width;
			}
			widths = split(widths, "_");
			//print(widths);
			for (c=0;c<num_of_channels;c++){
				for (c2=0;c2<num_of_channels;c2++){
					if (c<c2) {
						ab_names = antibodyNames[c]+"_"+antibodyNames[c2];
						c_infos = antibody_channel_info[c]+antibody_channel_info[c2];
						c_colours = antibodyColours[c]+"_"+antibodyColours[c2];
						ws = widths[c]+"_"+widths[c2];
						annotateMerge(ab_names, c_infos, c_colours, ws, h_indent, v_indent);
						saveAs("PNG", condFile + File.separator + "Merge"+c+"-"+c2+"_"+ imageNameParts[2] + ".png");
						close();
					}}}
					
			if (num_of_channels > 3){
				for (c=0;c<num_of_channels;c++){
					c1 = c;
					c2 = (c+5)%4;
					c3 = (c+6)%4;
					ab_names = antibodyNames[c1]+"_"+antibodyNames[c2]+"_"+antibodyNames[c3];
					c_infos = antibody_channel_info[c1]+antibody_channel_info[c2]+antibody_channel_info[c3];
					c_colours = antibodyColours[c1]+"_"+antibodyColours[c2]+"_"+antibodyColours[c3];
					ws = widths[c1]+"_"+widths[c2]+"_"+widths[c3];
					annotateMerge(ab_names, c_infos, c_colours, ws, h_indent, v_indent);
					saveAs("PNG", condFile + File.separator + "Merge"+c1+"-"+c2+"-"+c3+"_"+imageNameParts[2] + ".png");
					close();
				}}}
			
				
		//Save Single Images
		selectImage(animal_name +"_"+antibodyNames[0]);
		saveAs("PNG", condFile + File.separator + channel_orders[0]+ "_" + hemisphere + region + ".png");
		close();
		if (num_of_channels > 3) {
			selectImage(animal_name + "_" + antibodyNames[3]);
			saveAs("PNG", condFile + File.separator + channel_orders[3]+ "_" + hemisphere + region + ".png");
			close();
		}
		if (num_of_channels > 2) {
		selectImage(animal_name + "_" + antibodyNames[2]);
		saveAs("PNG", condFile + File.separator + channel_orders[2]+ "_" + hemisphere + region + ".png");
		close();
		}
		selectImage(animal_name + "_" + antibodyNames[1]);
		saveAs("PNG", condFile + File.separator + channel_orders[1]+ "_" + hemisphere + region + ".png");
		close();
		close("*Overlay*");
		close(images[i]);

	}
		closeAll();
}	

macro "Add Labels Action Tool - R00ffL33c3L36c6L39c9L3ccc"{
	label = getString("Label?", "default");
	scale = getString("ScaleBar?", "default");
	getDimensions(width, height, channels, slices, frames);
	setFont("Calibri", height/10, "bold antialiased");
	setJustification("left");
	setColor("white");
	
	Overlay.drawString(label, height/51.2, width/17.1, 0.0);
	Overlay.show();
	run("Scale Bar...", "width="+scale+" height=100 thickness="+height/200+" font="+height/20.5+" location=[Lower Left] bold overlay");
}
	
macro "Fluorescence 3D Object Analysis Action Tool - L3024L5044L2151L2353 Lc0b4Le0d4Lb1e1Lb3e3 Cf00 V0688 Cf0f V8688"{
		//Get Channel information
	//excel = "C:\\Users\\jm3923\\OneDrive - Imperial College London\\ImageJ\\Experiments\\p-Tau.GFAP\\Data Analysis\\Data Analysis.xlsx";
	get_channel_data();
	get_channel_info(true, false, false, true); //Returns channel_names, channel_numbers, channel_colors, channel_thresholds, and num_channels based on the user input 
	openFiles(); //Asks user for directory and opens all lif files in the directory, returning Directory and filelist as global variables
	openFilesZip();  //Opens all zip files from global Directory variable
	close("*virus");
	close("*setting*");
	images = getList("image.titles"); //get list of image titles
		//Initialise Excel writer and make subfile
	analysis_file = Directory + "\\Image Analysis";
	File.makeDirectory(analysis_file);
	initialize_excel();
 	//Loop through each image stack
 	for (i=0;i<lengthOf(images);i++){
 		//Get animal and image information
 		selectImage(images[i]);
		getNameParts(images[i]); //Takes image title formatted as (animalName_Hemisphere.BrainRegion) and Returns animal_name, hemisphere, brain_region as variables
		orientate(hemisphere, images[i]); //Orientate to look like left hemisphere
		remove_non_ROI(images[i], (i*2), ((i*2)+1));
		condition_file = analysis_file + "\\"+ animal_name;
		File.makeDirectory(condition_file);
		//Analyse fluorescent objects for each channel
		channels_with_objects = ""; //Initialise to store whch channels have objects
		for (j=0; j < num_channels; j++){
			selectImage(images[i]);
			run("Duplicate...", "title=[C"+j+1+"_unfiltered] duplicate channels=" + j+1); //Duplicate channel
			run("Duplicate...", "title=[C"+j+1+"_filtered] duplicate channels=" + j+1); //Duplicate channel
			set_redirect_3DObjectCounter("C"+j+1+"_unfiltered");
			runMacro(Directory+"\\.bin\\C"+j+1+"_Filters.ijm"); //Apply filters
			
			num_objects = 0; //Initialise 0 objects
			//If default threshold given by user get the default threshold at slice 6 apply to 3D object counter
			if (channel_thresholds[j] == "default"){
				get_stack_threshold("C"+j+1+"_filtered"); //Gets default threshold at slice 6 and returns in global new_threshold variable
				run("3D Objects Counter", "threshold="+new_threshold+" slice=6 min.=200 max.=Infinity objects statistics summary"); //3D Object Analysis
				selectImage("Masked image for C"+j+1+"_filtered redirect to C"+j+1+"_unfiltered");
				saveAs(".tif", condition_file + "\\"+j+1+"_"+region+".tif");
				close();
				selectImage("Objects map of C"+j+1+"_filtered redirect to C"+j+1+"_unfiltered");
				rename("C"+j+1+"_objects");
				Table.rename("Statistics for C"+j+1+"_filtered redirect to C"+j+1+"_unfiltered", "Results"); //Rename results table
				num_objects = nResults; //Get number of objects
			} else {
				Stack.getStatistics(voxelCount, mean, min, max, stdDev); //Get max pixel value
				//If max pixel value is greater than threshold the 3D object counter can be run
				if (max > channel_thresholds[j]){
					run("3D Objects Counter", "threshold="+channel_thresholds[j]+" slice=6 min.=200 max.=Infinity objects statistics summary"); //3D Object Analysis
					selectImage("Masked image for C"+j+1+"_filtered redirect to C"+j+1+"_unfiltered");
					saveAs(".tif", condition_file + "\\"+j+1+"_"+region+".tif");
					close();
					selectImage("Objects map of C"+j+1+"_filtered redirect to C"+j+1+"_unfiltered");
					rename("C"+j+1+"_objects");
					Table.rename("Statistics for C"+j+1+"_filtered redirect to C"+j+1+"_unfiltered", "Results"); //Rename results table
					num_objects = nResults; //Get number of objects
					}}
			//save results to excel if there are any object		
			if (num_objects > 0){
				save_to_excel("Results", channel_names[j]);
				channels_with_objects = channels_with_objects + " C"+j+1+"";
				} 
			//Create results table of 0 if there are no objects
			if (num_objects == 0){ 
			Table.create("Results");
			setResult("Count", 0, 0);
			run("Read and Write Excel", "stack_results sheet=["+channel_names[j]+"] file_mode=queue_write");
			run("Clear Results");}}
			
		//Colocalise fluorescent objects for each channel
		channels_with_objects = split(channels_with_objects, " "); //Split channels with objects into array for iteration
		for (j=0; j < lengthOf(channels_with_objects); j++){
			for (v=0; v < lengthOf(channels_with_objects); v++){
				C1 = channels_with_objects[j];
				C2 = channels_with_objects[v];
				//Only run colocalisation if they aren't the same channel
				if (C1 != C2){
					run_coloc_and_save(C1+"_objects", C2+"_objects", ""+channel_names[j]+" Colocalisation with "+channel_names[v]); //Save into excel sheet called C1 Colocalisation with C2
					}
			}}
		//Close unnecessary images
		close("*C1*");
		close("*C2*");
		close("*C3*");
		close("*C4*");
		close("*objects*");
		close(images[i]);
		 //Close all images with titles in the string separated by space
		}
	 	write_to_excel(); //Export all results to excel
	 	closeAll(); //Close everything
		}
		
macro "Fluorescence Intensity Action Tool -  C000Df0Df1Df2Df3Df4Df5C000De0De1De2De3C000Df6C000Dd0C000Dd1C000De4C001Df7C001Dd2C001C002Df8C002De5C002Df9C002Dd3C002C003C004De6C004DffC004DfeC004DfdC004DeeC004C005DfaC005Dc0C005DefC005Dd4C005Dc1De7DfcC005DfbC005C006Dc2DedC006Dd5C006D1eC006D0eC006D0dC006De8C006DdfDeaC006D5fC006D2eC006D02DecC006D6fC007D91De9C007D1dC007Dc3Dd6DebC007D4fD90C007D0cDdeC007D1cDabDdaC007D12C007D3fDbbC007D10DceDd7DddC007DbcC007D01D1fD2fC007D00Dc4C007D20D40D93DaaDb6DbeDcdC007D09D13DcfC008D0fD21Da0C008D05D0aD22D50Db5Dc5C008D08D0bD81DbaDdcC008D11D9bDc9C008D03D06D15D32D80DacDccDdbC008D18D1bD3eD9fDa1DbdDd9C008D04D19D7fDd8C008D14D16D29D30D53C008D2dD82Da3Da9DafDb0Db3C008D23D92Dc8C008D83Da6C008D1aD98Db4DcbC008D70DaeDc7C008D24D26D2cD60C008D44D51Db2C008D31D42DbfDc6DcaC009D52D62D9eDa2Db1C009D41D43Da5C009D17D28D45D4eD84D94Da4C009D54D71D85D8cDa7DadC009D6eDb7Db8Db9C009D35D76D86C009D72D96D99C009D5eD73D9dC009D07D63D9cC009D25D34D36D5dD95D97C009D33D67D8eC009D2bD6dD8fC009D2aD38D61D7dD87Da8C009D46D5aD8bC009D3cD3dD55D66D7eD8aC00aD27D4dC00aD8dD9aC00aD6cC00aD37D77D79C00aD68D75D89C00aD69D7aC00aD5bC00aD47D4bD65C00aD57D58D6aD74D7bD7cC00aD4aD4cD6bC00aD39D56D59D64C00aD3bD48D78D88C00aD3aC00aD5cC00bD49"{
		get_channel_data();
		get_channel_info(true, true, false, false); //Returns channel_names, channel_numbers, channel_colors, channel_thresholds, and num_channels based on the user input 
		Dialog.create("Analysis Specification");
		Dialog.addCheckbox("ROI Analysis?", true);
		Dialog.addCheckbox("Add binarization?", false);
		Dialog.show();
		ROI_analysis = Dialog.getCheckbox();
		binarization = Dialog.getCheckbox();
		openFiles(); //Asks user for directory and opens all lif files in the directory, returning Directory and filelist as global variables
		openFilesZip();  //Opens all zip files from global Directory variable
		images = getList("image.titles"); //Get list of image titles
   		initialize_excel();
		//Make new file for saving analysis result images
   		saveFile = Directory + File.separator + "Image Analysis";
   		File.makeDirectory(saveFile);
   		//Loop through all image stacks
 		
   		for (i=0; i<lengthOf(images); i++) {
   				//Initialise: Get name parts from image, split channels, and create duplicates for analysis
   			getNameParts(images[i]); //Takes image title formatted as (animalName_Hemisphere.BrainRegion) and Returns animal_name, hemisphere, brain_region as variables
			orientate(hemisphere, images[i]); //Orientate to look like left hemisphere
				//Make separate file for each condition
			condFile = saveFile + File.separator + animal_name;
			File.makeDirectory(condFile);
			
			if (ROI_analysis == true){remove_non_ROI(images[i], (i*2), (i*2)+1);} //Crops the image based on the ROI in the manager at the provided index and then clears the outside of the cropped image based on the ROI in the manager at the provided index
			run("Set Measurements...", "integrated area_fraction display redirect=None decimal=3"); //Set measurements
			for (c=0;c<num_channels;c++){
				selectImage(images[i]); //Select multi-channel image stack
				run("Duplicate...", "title=["+channel_names[c]+"_"+animal_name+"] duplicate channels="+channel_numbers[c]); //Isolate channel
					//Get IntDen
				if (binarization == true){
					run("8-bit");
							//create binary mask
					selectImage(channel_names[c]+"_"+animal_name);
					run("Duplicate...", "title=["+channel_names[c]+"_"+animal_name+"_binary] duplicate");
					run("Median...", "radius=2 stack");
					setOption("BlackBackground", false);
					setThreshold(0, 3300);
					run("Convert to Mask", " ");
							//Apply mask
					imageCalculator("AND create stack", ""+channel_names[c]+"_"+animal_name+"_binary",""+channel_names[c]+"_"+animal_name);
					rename(channel_names[c]+"_"+animal_name);}
				if (ROI_analysis == true){roiManager("select", (i*2)+1);}
				Stack.getDimensions(width, height, channels, slices, frames); //Get number of slices
				if (ROI_analysis == true){roiManager("select", (i*2)+1);} //Select ROI
				for (s = 2; s <= slices -1; s++) { //Iterate through each slice
					  Stack.setSlice(s); //Set the slice
					  run("Measure"); //Measure the IntDen of the slice
					}
				save_to_excel("Results", ""+channel_names[c]+" Total"); //Save results to excel sheet named after channel name
				close(channel_names[c]+"_"+animal_name); //Close isolated channel
				close("*binary*");
				close("*projection*");
				close("*png*");
			}
			close(images[i]); //Close multichannel image stack
   		}
   		write_to_excel(); //Export to excel
   		closeAll(); //Close everything
} 

	
macro "Create Inset Zooms Action Tool - CfffD00D01D02D05D08D09D0aD0bD0cD0dD0eD0fD10D11D19D1aD1bD1cD1dD1eD1fD20D2aD2bD2cD2dD2eD2fD3bD3cD3dD3eD3fD4bD4cD4dD4eD4fD50D55D5bD5cD5dD5eD5fD6bD6cD6dD6eD6fD7bD7cD7dD7eD7fD80D8aD8bD8cD8dD8eD8fD90D91D9cD9dD9eD9fDa0Da1Da2Da8DadDaeDafDb0Db1Db2Db3Db4Db5Db6Db7Db8DbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDe0De1De2De3De4De5De6De7De8De9DeaDebDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDffCfffD03D04D06D07D23D27D30D32D33D37D38D3aD40D45D4aD54D56D5aD60D65D6aD70D72D73D77D78D7aD83D87D9bDa3Da4Da5Da6Da7Db9DdfDefDfdDfeC2bfD12D18D21D24D25D26D29D34D35D36D42D43D44D46D47D48D52D53D57D58D62D63D64D66D67D68D74D75D76D81D84D85D86D92D98DacDbdDcaDceDdbDecC000D13D14D15D16D17D31D39D41D49D51D59D61D69D71D79D89D93D94D95D96D97D9aDa9C045D22D28D82D88C035C777D99DabDbaDbcDcbDcdDdcDdeDedC344DaaDbbDccDddC179Dee"{
	//Get information of images
	channel_names = getString("What are the names of each antibody (separate with space)?", "DAPI AT8 mCherry GFAP");
	channel_names = split(channel_names, " ");
	channel_numbers = getString("What are the channel numbers (separate with space)?", "1 2 3 4");
	channel_numbers = split(channel_numbers, " ");
	channel_colors = getString("What are the channel colors (separate with space)?", "Blue Green Red Magenta");
	channel_colors = split(channel_colors, " ");
	scale = getString("Scale Bar size?", "10");
	save_directory = getDirectory("Choose a Directory");
	image_name = getList("image.titles");
	//Split and project image channels
	split_channels(channel_names, channel_numbers, image_name[0], "Max");
	//Create merge
		//Get info for creating merge
		merge_info = "";
	for (i=0;i<lengthOf(channel_names);i++){
			channel_merge_info = get_merge_info(channel_colors[i], channel_names[i]);
			merge_info = merge_info + channel_merge_info;
			selectImage(channel_names[i]);
			run(channel_colors[i]);
		}
		//Create merge
	run("Merge Channels...", "" + merge_info + "create keep");
	rename("Merge");
		//Wait for user to ajust image settings
	run("Brightness/Contrast...");
	waitForUser("Adjust Brightness");
		//Draw ROIs
	setTool("rectangle");
	run("ROI Manager...");
	waitForUser("Draw ROIs for desired inset zooms");
	//Iterate through ROIs and create labelled insets
	nROI = roiManager("count");
	for (i=0;i<nROI;i++){
		//Iterate through channels and create crop for each
		for (v=0;v<lengthOf(channel_names);v++){
			//Select image and ROI
			selectImage(channel_names[v]);
			roiManager("select", i);
			//Duplicate and add labels
			channel_name = channel_names[v]+".inset_"+i;
			run("Duplicate...", "title=["+channel_name+"] duplicate");
			add_labels(channel_names[v],scale);
			saveAs("PNG", save_directory + File.separator + channel_name + ".PNG");
			close();
		}
		//Same for merge
		selectImage("Merge");
		roiManager("select", i);
		channel_name = "Merge.inset_"+i;
		run("Duplicate...", "title=["+channel_name+"] duplicate");
		add_labels("Merge",scale);
		saveAs("PNG", save_directory + File.separator + channel_name + ".PNG");
		close();
	}
	
}
macro "Orientte Left Hemisphere Action Tool - CfffD00D07D08D09D0aD0bD0cD0fD10D18D19D1aD1bD1cD1fD29D2aD2bD2cD2fD3aD3bD3cD3fD4aD4bD4cD4fD5aD5bD5cD5fD6aD6bD6cD6fD7aD7bD7cD7fD89D8aD8bD8cD8fD90D98D99D9aD9bD9cD9fDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDacDafDb0Db6Db7Db8Db9DbcDbfDc0Dc4Dc5Dc6Dc7Dc8Dc9DccDcfDd0Dd6Dd7Dd8Dd9DdcDddDdeDdfDe0De2DecDedDeeDefDf0Df2Df3DfbDfcDfdDfeDffC00fD01D02D03D04D05D06D11D12D13D14D15D16D17D20D21D22D23D24D25D26D27D28D30D31D32D33D34D35D36D37D38D39D40D41D42D43D44D45D46D47D48D49D50D51D52D53D54D55D56D57D58D59D60D61D62D63D64D65D66D67D68D69D70D71D72D73D74D75D76D77D78D79D80D81D82D83D84D85D86D87D88D91D92D93D94D95D96D97"{
run("Rotate 90 Degrees Left");	
}

macro "Orientate Right Hemisphere Action Tool - CfffD00D07D08D09D0aD0bD0cD0fD10D18D19D1aD1bD1cD1fD29D2aD2bD2cD2fD3aD3bD3cD3fD4aD4bD4cD4fD5aD5bD5cD5fD6aD6bD6cD6fD7aD7bD7cD7fD89D8aD8bD8cD8fD90D98D99D9aD9bD9cD9fDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDacDafDb0Db6Db7Db8Db9DbcDbfDc0Dc4Dc5Dc6Dc7Dc8Dc9DccDcfDd0Dd6Dd7Dd8Dd9DdcDddDdeDdfDe0De2DecDedDeeDefDf0Df2Df3DfbDfcDfdDfeDffC00fD01D02D03D04D05D06D11D12D13D14D15D16D17D20D21D22D23D24D25D26D27D28D30D31D32D33D34D35D36D37D38D39D40D41D42D43D44D45D46D47D48D49D50D51D52D53D54D55D56D57D58D59D60D61D62D63D64D65D66D67D68D69D70D71D72D73D74D75D76D77D78D79D80D81D82D83D84D85D86D87D88D91D92D93D94D95D96D97"{
run("Rotate 90 Degrees Left");
run("Flip Horizontally");
}

macro "Max Projection Action Tool - CfffD00D01D02D03D04D05D06D07D08D0aD0bD0cD0dD0eD0fD10D11D12D13D14D1aD1bD1cD1dD1eD1fD20D21D22D2aD2bD2cD2dD2eD2fD30D31D3aD3bD3cD3dD3eD3fD40D49D4aD4bD4cD4dD4eD4fD50D57D58D59D5aD5bD5fD66D67D68D69D6aD6bD6fD75D76D77D78D7bD7fD85D86D87D8fD96D97D9bD9fDa0Da7DaaDabDafDb0DbaDbbDbcDbdDbeDbfDc0Dc1DcbDccDcdDceDcfDd0Dd1Dd2DdbDdcDddDdeDdfDe0De1De2De3DebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6DfbDfcDfdDfeDffCcccD79C7cdDd4CdffD25D36C444D99CcffD64CadeDb7CfffD7cC29bDe6CbefD62CaefD61D74CfffD5cD88D8bD8cD9cDacDadC3acDc9CdffDf7CbefD33D42D52D55CfffD09D15D23D41D48D56D6cDa6De4DfaC19bDd6Dd9De7De8De9CdddD6dC9eeD71D72D73D81D82D83D91CeffD95C888D8aCdffD17D18D19D26D27D28D29D35D37D38D39D51CaefD34D43D44D45D53D54C3bdDa3Da4Db2Db3Db4Db5Dc3Dc4CeeeD5eDaeCeffDcaC5cdDa2Da5CeffDdaDeaC18bDc7CcddD7eD8eC9deDc2Df9CdffD16D24D46D70D80C666Db8CaefD84D92CeeeD5dD6eD7dC4acDc6CddeD9dD9eCeffD32D47CbbbD7aD9aCeffD60D65D90C6cdDc5C18aDd7Dd8CcccD98Db9C8cdDe5C555Da9CbdeDf8CcefD63Db1CdddD8dC999Da8C9deD94Da1C777D89CbefD93C5bcDd5C8deDb6CbeeDd3"{
run("Z Project...", "projection=[Max Intensity]");
}

macro "Average Projection Action Tool - CfffD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD20D23D24D25D26D27D28D29D2aD2bD2cD2dD30D33D34D35D36D37D38D39D3aD3bD3cD40D43D44D45D46D47D48D49D4eD50D5cD5dD5eD60D61D63D64D65D66D67D68D69D6aD6bD6cD6dD6eD70D80D81D83D84D85D86D87D88D89D8aD8bD8cD8dD8eD90D91D9bD9cD9dD9eDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaeDb0Db1Db2Db3Db4Db5Db6Db7Db8Db9DbaDbbDbcDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDccDcdDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDddDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeCbbbD76D7bDbdDcfCbabD94D95D96D97CccdD3dD4dCaabD01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD54D55D56D57D58D59D98DceCcccD3fD4fD5fD6fD73D75D7cD7eD8fD9fDafDbfCbbbD2eD3eD74D7dD99CddeD22DadC99aD62CcccD77D7aDbeCbbbD2fDabDefCdddD42D71D92DaaCeeeD21C989D00D7fCbbcD4bD5aD78D79DffCdddD9aCeeeD31D41D51DdeCaaaD53D93CcccD1fD52CeeeD4aD5bCaaaD4cDacC999D0fCdddD32CaaaD82"{
run("Z Project...", "projection=[Average Intensity]");	
}

macro "Split Channels Action Tool - CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD20D21D22D23D24D25D26D27D28D29D2aD2bD30D31D32D33D34D35D36D37D38D39D3aD3fD40D41D42D43D44D45D46D47D48D4eD4fD50D51D52D53D54D55D56D57D5dD5eD5fD60D61D62D63D64D65D66D6cD6dD6eD6fD70D71D72D73D74D75D7bD7cD7dD7eD7fD80D81D82D83D84D8aD8bD8cD8dD8eD8fD90D91D92D93D99D9aD9bD9cD9dD9eD9fDa0Da1Da2Da8Da9DaaDabDacDadDaeDafDb0Db1Db6Db7Db8Db9DbaDbbDbcDbdDbeDbfDc0Dc5Dc6Dc7Dc8Dc9DcaDcbDccDcdDceDcfDd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDe3De4De5De6De7De8De9DeaDebDecDedDeeDefDf2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC777D0eD49D58D67D6bD76D7aD85D89D94D98Da7Df1C777D0fD1dD1eD1fD2cD2dD2eD2fD3bD3cD3dD3eD4aD4bD4cD4dD59D5aD5bD5cD68D69D6aD77D78D79D86D87D88D95D96D97Da3Da4Da5Da6Db2Db3Db4Db5Dc1Dc2Dc3Dc4Dd0Dd1Dd2Dd3De0De1De2Df0"{
run("Split Channels");
}		
    
 macro "Close All Action Tool - Cf00L00ffL0ff0" {
    	closeAll()
    }
macro "Convert Image to Tool Icon... Action Tool - "{

  requires("1.35r");
  if (bitDepth!=8 || getWidth>16 || getHeight>16)
     exit("This macro requires 16x16 8-bit image");
  Dialog.create("Image 2 Tool");
  Dialog.addString("Tool name", "myTool");
  Dialog.addCheckbox("Transparent Color", true);
  Dialog.addNumber("Value", 0);
  Dialog.show();
  mytool = Dialog.getString();
  allPixels = !Dialog.getCheckbox();
  transparent = Dialog.getNumber();
  getLut(r,g,b);
  getRawStatistics(area, mean, min, max);
  ts="macro '"+mytool+" Tool - ";
  for (i=0; i<=max; i++) {
      if (allPixels || i!=transparent) {
          r2=floor(r[i]/256*16);
          g2=floor(g[i]/256*16);
          b2=floor(b[i]/256*16);
          color = "C"+toHex(r2)+toHex(g2)+toHex(b2);
          if (!endsWith(ts, color)) ts=ts+color;
          for (x=0; x<getWidth; x++) {
              for (y=0; y<getHeight; y++) {
                  if (getPixel(x,y)==i)
                      ts=ts+"D"+toHex(x)+toHex(y);
              }
          }
      }
  }
  ts=ts+"'{\n\n}";
  macrodir = getDirectory("macros");
  if (!endsWith(mytool,".txt")) mytool = mytool+".txt";
  f = File.open(macrodir+mytool);
  print (f, ts);
  File.close(f);
  open(macrodir+mytool);
}		
//FUNCTIONS____________________________________________________________________________________________

function annotateMerge(channel_names, channel_infos, channel_colours, widths, indent, v_indent){
			//Merges channels in channel_names and annotates them with text coloured as channel colours, evenly spaced alog the top. Widths should be widths of each text element which is need to be computed beforehand
			channel_name = split(channel_names, "_");
			channel_colour = split(channel_colours, "_");
			width = split(widths, "_");
			
			run("Merge Channels...", "" + channel_infos + "create keep");
			for (i=0;i<lengthOf(channel_colour);i++) {
				if (i>0) {
					h_indent_i = h_indent_i + width[i-1];
				} else { if (i == 0){
					h_indent_i = 0;
				}}
				
				setColor(channel_colour[i]);
				Overlay.drawString(channel_name[i], h_indent_i + indent, v_indent);
				Overlay.show();
			}
			run("Scale Bar...", "width=50 height=100 thickness=5 font=50 location=[Lower Left] bold overlay");
	}
  function Filter_3D() {
  	//Simple Z-Stack filter. Gaussian, subtract background, median
  	run("Gaussian Blur...", "sigma=2 stack");
	run("Subtract Background...", "rolling=20 stack");
	run("Median...", "radius=2 stack");
  }
  
  function openFiles() {
	//open every lif file in directory
	if (Directory == "nothing"){var Directory = getDirectory("Choose a Directory");}
	var filelist = getFileList(Directory); 
	for (i = 0; i < lengthOf(filelist); i++) {
    	if (endsWith(filelist[i], ".lif")) { 
        	open(Directory + File.separator + filelist[i]);
        	opened_lif = filelist[i];
        	exp_name = split(opened_lif, " - ");
        	var exp_name = exp_name[0];
    	} 
	}
  }
  
  function openFilesZip() {
	//Open every zip file in directory
	for (i = 0; i < lengthOf(filelist); i++) {
    	if (endsWith(filelist[i], ".zip")) { 
        	open(Directory + File.separator + filelist[i]);
    	} 
	}
  }
  
  function closeAll() {
  	//Close every window
    	close("*");
    	close("Results");
   		close("Summary");
  	 	close("ROI Manager");
   		close("Threshold");
   		//close("Log");
   		close("B&C");
   		close("Debug");
   		close("Exception");
   		close("*Overlay*");
    }
    
  function drawAndMeasure(){
  	//Sets freehand tool and adds drawn ROI to manager. Then measures the ROI area and selects results window
  	setTool("freehand");
	waitForUser("Draw around inclusion area");
	roiManager("add");
	run("Set Measurements...", "area redirect=None decimal=3");
	run("Measure");
	selectWindow("Results");
  }
  
 
  function colourSplit(title, amyloidChannel_Colour, dapiChannel, mCherryChannel_Colour, duplicate) {
  		
  		animal_name = imageNameParts[1];
  		
  		amyloid = split(amyloidChannel_Colour,"_");
  		amyloidChannel = amyloid[0];
  		amyloidColour = amyloid[1];
  		
  		mCherry = split(mCherryChannel_Colour,"_");
  		mCherryChannel = mCherry[0];
  		mCherryColour = mCherry[1];
  			
  		selectImage(title);
  		run("Duplicate...", "duplicate title=[Amyloid] duplicate channels=" + amyloidChannel);
		rename(animal_name + "_Amyloid");
		close("Amyloid");
		selectImage(title);
		run("Duplicate...", "duplicate title=[mCherry] duplicate channels=" + mCherryChannel);
		rename(animal_name + "_mCherry");
		close("mCherry");
		selectImage(title);
		run("Duplicate...", "duplicate title=[DAPi] duplicate channels=" + dapiChannel);
		rename(animal_name + "_DAPi");
		close("DAPi");
		
  	if (duplicate == true) {
  		selectImage(animal_name + "_Amyloid");
  		run("Duplicate...", "duplicate title=[" + animal_name + "_AmyloidToAnalyse]");
  		selectImage(animal_name + "_mCherry");
  		run("Duplicate...", "duplicate title=[" + animal_name + "_mCherryToAnalyse]");
  		selectImage(animal_name + "_DAPi");
  		run("Duplicate...", "duplicate title=[" + animal_name + "_DAPiToAnalyse]");
  		}
  }

  function splitAndZ(title, antibodies_Channels_Colours, enhance, duplicate, merge, automation, convertRGB) {
  		//Splits channels and merges them. Provides customisability in the processes applied to each image, including enhancing contrast, duplicating multiple times, automating enhncements, RGB conversion.
  		red = "";
  		green = "";
  		blue = "";
  		grey = "";
  		cyan = "";
  		magenta = "";
  		yellow = "";
  		
  		antibody_channel_colour = split(antibodies_Channels_Colours, ".");
  		antibody_channel_info = "";
  		merge_info = "";
  		
  		for (a=0;a<lengthOf(antibody_channel_colour);a++){
  			antibody_info = antibody_channel_colour[a];
  			a_name_parts = split(antibody_info,"_");
  			a_name = a_name_parts[0];
  			a_channel = a_name_parts[1];
  			a_colour = a_name_parts[2];
  			
  			if (a_colour == "Red") {
  			a_channel_info = "c1=" + animal_name + "_" + a_name + " ";
  		} else if (a_colour == "Green") {
  			a_channel_info = "c2=" + animal_name + "_" + a_name + " ";
  		} else if (a_colour == "Blue") {
  			a_channel_info = "c3=" + animal_name + "_" + a_name + " ";
  		} else if (a_colour == "Grey") {
  			a_channel_info = "c4=" + animal_name + "_" + a_name + " ";
  		} else if (a_colour == "Cyan") {
  			a_channel_info = "c5=" + animal_name + "_" + a_name + " ";
  		} else if (a_colour == "Magenta") {
  			a_channel_info = "c6=" + animal_name + "_" + a_name + " ";
  		} else if (a_colour == "Yellow") {
  			a_channel_info = "c7=" + animal_name + "_" + a_name + " ";
  			} 
  		print(a_name);
  		print(a_channel_info);
  		if (enhance == true) {
  			selectImage(title);
  			run("Duplicate...", "title=["+a_name+"] duplicate channels=" + a_channel);
			run("Z Project...", "projection=[Max Intensity]");
			if (automation == false){
				run("Brightness/Contrast...");
				waitForUser;
			} else {run("Enhance Contrast", "saturated=0.35");}
			run(a_colour);
			rename(animal_name + "_" + a_name);
			close(a_name);
  			} else {
	  		selectImage(title);
  			run("Duplicate...", "title=["+a_name+"] duplicate channels=" + a_channel);
			run("Z Project...", "projection=[Max Intensity]");
			run(a_colour);
			rename(animal_name + "_" + a_name);
			close(a_name);}
  		
  		if (duplicate == true) {
  		selectImage(animal_name + "_" + a_name);
  		run("Duplicate...", "title=[" + animal_name + "_" + a_name + "_toanalyse]");}
  		
  		if (convertRGB == true) {
  		selectImage(animal_name + "_" + a_name);
  		run("RGB Color");}
  		
  		antibody_channel_info = antibody_channel_info + a_channel_info + ",";
  		print(antibody_channel_info);
  		merge_info = antibody_channel_info + a_channel_info;
  		}
  		
  		if (merge == true) {
  		run("Merge Channels...", "" +  merge_info + "create keep");
  		run("RGB Color");}
  		
  		antibody_channel_info = split(antibody_channel_info, ",");
  		return antibody_channel_info;
  }
  	
  function getNameParts(exp_animal_hemisphere_region) {
  	//Images must be named with the syntax:ExperimentName - AnimalID_Hemisphere.BrainRegion
  	exp_animal_hemisphere_region = split(exp_animal_hemisphere_region, " - "); //separate experiment name
	var exp_name = exp_animal_hemisphere_region[0]; //set experiment name
	animal_hemisphere_region = exp_animal_hemisphere_region[1];
	print(animal_hemisphere_region);
	animal_hemisphere_region = split(animal_hemisphere_region, "_"); //separate animal ID
	var animal_name = animal_hemisphere_region[0]; //set animal ID
	//var hemisphere = animal_hemisphere_region[2];
	//var region = animal_hemisphere_region[1];
	
	hemisphere_region = animal_hemisphere_region[1];
	hemisphere_region = split(hemisphere_region, "."); //separate hemisphere and brain region
	var hemisphere = hemisphere_region[0]; //set hemisphere
	var region = hemisphere_region[1]; //set brain region
  	
  	//animal_name = animal_hemisphere_region[0];
  	//animal_name = split(animal_name, ".");
  	//var animal_name = animal_name[0];
  }
  
  function resetROIandResults() {
  	//Clears ROI manager and results
  	roiManager("reset");
	run("Clear Results");
	run("Select None");
  }
  
  function combineAddDeleteRenameROIGroup(GroupNumber, NewName) {
  	RoiManager.selectGroup(GroupNumber);
			roiManager("Combine");
			roiManager("add");
			roiManager("delete");
			RoiManager.selectGroup(GroupNumber);
			roiManager("Rename", NewName);
  }

  function orientate(hemisphere, image){
  	//Orientates images to be upright and represented as a left hemisphere. Hemisphere needs to be "LH" or "RH". Only works on stacks
  	selectImage(image);
  	run("Rotate 90 Degrees Left");
		if (hemisphere == "RH") {
			run("Flip Horizontally", "stack");
		}	
  }

  function split_channels(channel_names, channel_numbers, image){
  	//Duplicates colour channels of Z-stack and names them based on channel_names. channel_names and channel_numbers need to be arrays
	for (v=0;v<lengthOf(channel_names);v++){
		selectImage(image);
		run("Duplicate...", "title=["+channel_names[v]+"] duplicate channels="+channel_numbers[v]);
	}
}

function save_to_excel(table_name, sheet_name){
			//Performs a queue-write for information in table_name into excel sheet with sheet_name and clears results afterwards
			Table.rename(table_name, "Results");
			run("Read and Write Excel", "stack_results sheet=["+sheet_name+"] file_mode=queue_write");
			run("Clear Results");
		}
		
function clean_table(table_name, columns_to_keep){
				//Deletes all but 3 columns in a table of any name. columns_to_keep must be a string with each column name separated by a space
				columns = split(columns_to_keep, " ");
				Table.rename(table_name, "Results");
				selectWindow("Results");
				headings = split(Table.headings, "	");
				for (j=1; j<headings.length; j++) {
					if (headings[j] != columns[0]) {
						if (headings[j] != columns[1]) {
							if (headings[j] != columns[2]) {
							Table.deleteColumn(headings[j]);
							}}}
					}
				Table.update;
			}
			
function write_to_excel(){
 		//Exports all queued data to excel
 		run("Read and Write Excel", "no_count_column file_mode=write_and_close");
 		
 	}
 function projection(type, name){
 	//Z-Projection of stack. Renames projection as "'name'_projection"
 	run("Z Project...", "projection=["+type+" Intensity]");
 	rename(name+"_projection");
 }

function run_coloc_and_save(imagea, imageb, excel_sheet_name){
				run("3D MultiColoc", "image_a="+imagea+" image_b="+imageb+"");
				Table.rename("Colocalisation", "Results");
				selectWindow("Results");
				headings = split(Table.headings, "	");
				for (j=1; j<headings.length; j++) {
					if (headings[j] != "LabelObj") {
						if (headings[j] != "P1") {
							if (headings[j] != "O1") {
							Table.deleteColumn(headings[j]);
							}}}
					}
				Table.update;
				run("Read and Write Excel", "stack_results sheet=["+excel_sheet_name+"] file_mode=queue_write");
				run("Clear Results");
			}
 	
function add_labels(label, scale){
	getDimensions(width, height, channels, slices, frames);
	setFont("Calibri", height/10, "bold antialiased");
	setJustification("left");
	setColor("white");
	
	Overlay.drawString(label, height/51.2, width/17.1, 0.0);
	Overlay.show();
	run("Scale Bar...", "width="+scale+" height=100 thickness="+height/200+" font="+height/20.5+" location=[Lower Left] bold overlay");
}

function split_channels(channel_names, channel_numbers, image_name, projection_type){
  //Duplicates colour channels of Z-stack and names them based on channel_names. channel_names and channel_numbers need to be arrays
	for (v=0;v<lengthOf(channel_names);v++){
		selectImage(image_name);
		run("Duplicate...", "title=["+channel_names[v]+"] duplicate channels="+channel_numbers[v]);
		
		if (projection_type != "None"){
			run("Z Project...", "projection=["+projection_type+" Intensity]");
			close(channel_names[v]);
			rename(channel_names[v]);
		}
	}
}

function get_merge_info(antibody_color, image_name){
	colors = newArray("Red","Green","Blue","Grey","Cyan","Magenta","Yellow");
	antibody_merge_info = " ";
	for (c=1;c<lengthOf(colors)+1;c++){
		if (antibody_color == colors[c-1]){
			antibody_merge_info = "c"+c+"="+image_name+" ";
		}}
	return antibody_merge_info;
	}
	
function get_channel_info(names, numbers, colors, thresholds){
	Dialog.create("Antibody Info");
	Dialog.addMessage("Separate Inputs with a Space");
	if (names == true){
		Dialog.addString("Antibody Names", default_names, 30);}
 	if (numbers == true){
 		Dialog.addString("Channel order for tiling", "1 2 3 4", 30);}
 	if (colors == true){
		Dialog.addString("Antibody Colors", default_colors, 30);}
	if (thresholds == true){	
		Dialog.addString("Antibody Thresholds", default_thresholds, 30);}	
	// Finally show the GUI, once all parameters have been added
	Dialog.show();
 	if (names == true){string_channel_names = Dialog.getString();
 		var channel_names = split(string_channel_names, " ");
 		var num_channels = lengthOf(channel_names);}
	if (numbers == true){channel_numbers = Dialog.getString();
		var channel_numbers = split(channel_numbers, " ");
		var num_channels = lengthOf(channel_numbers);}
	if (colors == true){channel_colors = Dialog.getString();}
	if (thresholds == true){channel_thresholds = Dialog.getString();
		var channel_thresholds = split(channel_thresholds, " ");}}
		
function close_list(close_string){
			close_string = split(close_string, " ");
			for (t=0;t<lengthOf(close_string);t++){
				close(close_string[t]);
			}
			
function get_stack_threshold(stack){
					selectImage(stack);
					Stack.setSlice(6);
					setAutoThreshold("Default dark");
					getThreshold(new_threshold, upper);
					var new_threshold = new_threshold;
				}
				
function remove_non_ROI(image, roi_index, cropped_roi_index){
				wait(100);
				selectImage(image);
				roiManager("select", roi_index);
				run("Crop");
				roiManager("select", cropped_roi_index);
				run("Clear Outside", "stack");
				roiManager("deselect");
				wait(100);
				}
				
function get_channel_data(){
	var Directory = getDirectory("Choose a Directory");
	data = File.openAsString(Directory+"\\.bin\\Channel_Data.txt");
	lines = split(data, "\n");
	var default_names = lines[0];
	var default_colors = lines[1];
	var default_thresholds = lines[2];
}

function initialize_excel(){
		excel_dir = Directory + File.separator + "Data Analysis";
		excel_file = excel_dir + File.separator + "Data Analysis.xlsx";
		File.makeDirectory(excel_dir);
		run("Read and Write Excel", "file=["+excel_file+"] file_mode=read_and_open");
	}
	
function set_redirect_3DObjectCounter(image_title){
	run("3D OC Options", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=["+image_title+"]");
}

function draw_and_add_ROI(image_title, cond_file){
   		selectImage(image_title);
		run("Duplicate...", "duplicate channels=1");
		rename("delete");
		run("Z Project...", "projection=[Max Intensity]");
		rename("MAX_delete");
		setTool("freehand");
		Roi.setDefaultGroup(7); //Yellow ROI
		waitForUser("Draw ROI");
		roiManager("add");
		run("Set Measurements...", "area display redirect=None decimal=3");
		run("Crop");
		getDimensions(width, height, channels, slices, frames);
		rename(animal_name+"."+width+"."+height);
		run("Measure");
		run("Read and Write Excel", "stack_results sheet=[Area] file_mode=queue_write");
		run("Clear Results");
		run("Set Measurements...", "display redirect=None decimal=3");
		run("Measure");
		run("Read and Write Excel", "stack_results sheet=[Labels] file_mode=queue_write");
		run("Clear Results");
		roiManager("Add");
		count = roiManager("count");
		roiManager("select", count-2);
		roiManager("rename", animal_name+"_"+region);
		roiManager("select", count-1);
		roiManager("rename", animal_name+"_"+region+"_Cropped");
		File.makeDirectory(condFile);
		saveAs("PNG", condFile + File.separator + "Cropped_" + region + ".PNG");
		close("Cropped_" + region + ".PNG");
		close(image_title);
		close("*delete*");}
