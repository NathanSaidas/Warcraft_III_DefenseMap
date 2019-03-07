Hopefully this file will provide insight to my future self on how to use it.

Precompile.bat -- Generates full jass text to be used in wc3
GenerateTemplates.bat -- Generates template text.

Modify the JassProject.project file to suit the needs of the project.

Precompile.Bat
    "Tools/JassTool.exe" -precompile /project="JassProject.project" /output="JassCompiled.txt" /clipboard

GenerateTemplates.bat
    "Tools/JassTool.exe" -template /file="Templates\ListTemplates.j"
    "Tools/JassTool.exe" -template /file="Templates\ObjectAutoComplete.j" -object
    "Tools/JassTool.exe" -template /file="Templates\ListAutoComplete.j"

