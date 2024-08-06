' Declare variables
Dim mainFolderPath, path, wsName
Dim i
Dim objExcel, objWorkbook, objSheet
Dim objFSO

' Function to select a folder
Function GetFolder()
    Dim objShell, objFolder
    Set objShell = CreateObject("Shell.Application")
    Set objFolder = objShell.BrowseForFolder(0, "Select a Folder", 0)
    If Not objFolder Is Nothing Then
        GetFolder = objFolder.Self.Path
    Else
        GetFolder = ""
    End If
End Function

' Set main folder path
mainFolderPath = GetFolder()


' Create FileSystemObject
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Create Excel application object
Set objExcel = CreateObject("Excel.Application")
' Disable alerts and screen updating
objExcel.DisplayAlerts = False
objExcel.ScreenUpdating = False
' Open the main workbook
Set objWorkbook = objExcel.Workbooks.Open(mainFolderPath & "/Data Analysis.xlsx")

' Loop through each sheet in the workbook
For i = 1 To objWorkbook.Sheets.Count
    ' Get sheet name
    wsName = objWorkbook.Sheets(i).Name
    ' Specify CSV file path
    path = mainFolderPath & "\" & wsName & ".csv"
    ' Copy sheet to new workbook
    objWorkbook.Sheets(wsName).Copy
    ' Delete the top row
    objExcel.ActiveSheet.Rows(1).Delete
    ' Save the copied sheet as CSV
    objExcel.ActiveWorkbook.SaveAs path, 6 ' 6 represents xlCSV format
    ' Close the newly created workbook
    objExcel.ActiveWorkbook.Close False
Next

' Close the main workbook
objWorkbook.Close False

' Release Excel objects
objExcel.Quit
Set objSheet = Nothing
Set objWorkbook = Nothing
Set objExcel = Nothing

' Release FileSystemObject
Set objFSO = Nothing
WScript.Echo "Sheets Saved to CSVs!"