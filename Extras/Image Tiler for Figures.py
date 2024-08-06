import os
import win32com.client
from tkinter import Tk
from tkinter.filedialog import askdirectory

def get_folder():
    root = Tk()
    root.withdraw()
    folder_path = askdirectory(title="Select a Folder")
    return folder_path

def is_image_file(file_path):
    ext = os.path.splitext(file_path)[1].lower()
    return ext in ['.jpg', '.jpeg', '.png', '.gif', '.bmp']

def insert_image(slide, image_path, ppt_top, ppt_left, img_size):
    image = slide.Shapes.AddPicture(image_path, 0, 1, ppt_left, ppt_top, img_size, img_size)
    image.PictureFormat.Contrast = 1
    image.PictureFormat.Brightness = 0.8

def import_images_recursively(ppt_pres, pp_slide, folder_path, ppt_top, ppt_left, img_size):
    fso = win32com.client.Dispatch("Scripting.FileSystemObject")
    folder = fso.GetFolder(folder_path)

    num_positions = 0
    num_groups = 0
    file_length = 0

    for file in folder.Files:
        if is_image_file(file.Path):
            file_length += 1
            name_parts = os.path.splitext(os.path.basename(file.Path))[0].split('_')
            if num_positions == 0:
                first_name = name_parts[1]
            if name_parts[1] == first_name:
                num_positions += 1

    if file_length != 0:
        num_groups = file_length / num_positions

    i = 0
    spacing = 3

    for file in folder.Files:
        if is_image_file(file.Path):
            pos = i // num_groups
            group = (i + num_groups) % num_groups
            ppt_left_new = ppt_left + (img_size * pos) + (img_size * group * num_positions) + \
                           (pos * spacing) + (group * num_positions * spacing)
            insert_image(pp_slide, file.Path, ppt_top, ppt_left_new, img_size)
            name_parts = os.path.splitext(os.path.basename(file.Path))[0].split('_')

            image_textbox = ppt_pres.Slides(1).Shapes.AddTextbox(
                1, ppt_left_new, ppt_top - 5, img_size, 30)
            image_textbox.TextFrame.TextRange.Text = name_parts[1]
            image_textbox.TextFrame.TextRange.Font.Size = 40
            image_textbox.TextFrame.TextRange.Font.Bold = True
            image_textbox.TextFrame.TextRange.Font.Color = 0xFFFFFF
            

            image_scalebar = ppt_pres.Slides(1).Shapes.AddShape(
                            1, ppt_left_new+5, ppt_top + img_size*0.9, img_size/4, img_size/70)
            image_scalebar.Fill.BackColor.RGB = 0xFFFFFF
            image_scalebar.Fill.ForeColor.RGB = 0xFFFFFF
            image_scalebar.Line.ForeColor.RGB = 0xFFFFFF

            i += 1
    
            
    for sub_folder in folder.SubFolders: 
        condition_name = str(sub_folder).split("\\")[-1].split("_")[1]   
        ppt_left = 300
        ppt_top += img_size + spacing
        sub_folder_textbox = ppt_pres.Slides(1).Shapes.AddTextbox(
              1, ppt_left - 180, ppt_top - 30 + img_size/2, img_size, 30)
        sub_folder_textbox.TextFrame.TextRange.Text = condition_name
        sub_folder_textbox.TextFrame.TextRange.Font.Size = 54
        sub_folder_textbox.TextFrame.TextRange.Font.Bold = True
        sub_folder_textbox.TextFrame.TextRange.ParagraphFormat.Alignment = 2
        sub_folder_textbox.Fill.BackColor.RGB = 0xFFFFFF
        sub_folder_textbox.Rotation = 270
        import_images_recursively(ppt_pres, pp_slide, sub_folder.Path, ppt_top, ppt_left, img_size)

def import_images_to_powerpoint():
    ppt_app = win32com.client.Dispatch("PowerPoint.Application")
    ppt_app.Visible = True
    ppt_pres = ppt_app.Presentations.Add()

    main_folder_path = get_folder()
    global ppt_top
    ppt_top = -250
    ppt_left = -20
    img_size = 10
    img_size = img_size * 100 / 3.53

    ppt_pres.PageSetup.SlideWidth = 3000
    ppt_pres.PageSetup.SlideHeight = 3000
    ppt_pres.Slides.Add(1, 1)
    import codecs
    import_images_recursively(ppt_pres, ppt_pres.Slides(1), main_folder_path, ppt_top, ppt_left, img_size)
    print(f'{main_folder_path.replace('/','\\')}\\Tiled Figure.pptx')
    ppt_pres.SaveAs(f'{main_folder_path.replace('/', '\\')}\\Tiled_Figure.pptx')
    

if __name__ == "__main__":
    first_run = True
    import_images_to_powerpoint()


