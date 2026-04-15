$word = New-Object -ComObject Word.Application
$word.Visible = $false
$htmlPath = "c:\Users\user\Desktop\project\STUDY_GROUP_FINDER_2\Project_Documentation.html"
$pdfPath = "c:\Users\user\Desktop\project\STUDY_GROUP_FINDER_2\Project_Documentation.pdf"

# format 17 is wdFormatPDF
$doc = $word.Documents.Open($htmlPath)
$doc.SaveAs([ref]$pdfPath, [ref]17)
$doc.Close()
$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
