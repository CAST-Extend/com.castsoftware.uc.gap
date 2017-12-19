goto to_run

setlocal EnableDelayedExpansion
"I:\BATCH\FART\fart.exe" "S:\Area Motor\BATCH\script_CASTMOT.txt" patata48 patata49 
"I:\BATCH\FART\fart.exe" "S:\Area Motor\BATCH\ftpMotorDB2.txt" patata48 patata49 
"I:\BATCH\FART\fart.exe" "S:\Area Motor\BATCH\ftpMotorCOB.txt" patata48 patata49 
"I:\BATCH\FART\fart.exe" "S:\Area Motor\BATCH\ftpMotorCPY.txt" patata48 patata49 
 
pause




ftp -s:script_CASTMOT.txt AMDAHLSVIL.RAS 1>script_CASTMOT_out.txt 2>script_CASTMOT_err.txt
pause
cd "S:\Area Motor\SOURCE_STAGING\DB2 Motor"
del /Q *.*
ftp -v -i -s:..\..\BATCH\ftpMotorDB2.txt 1>..\..\BATCH\ftpMotorDB2_log.txt 2>..\..\BATCH\ftpMotorDB2_err.txt
pause

cd "S:\Area Motor\SOURCE_STAGING\Motor Mainframe\Cobol\Tp-program" 
del /Q *.*
ftp -v -i -s:..\..\..\..\BATCH\ftpMotorCOB.txt 1>..\..\..\..\BATCH\ftpMotorCOB_log.txt 2>..\..\..\..\BATCH\ftpMotorCOB_err.txt
rename * *.cob
cd "S:\Area Motor\SOURCE_STAGING\Motor Mainframe\Cobol\Copybook"
del /Q *.*
ftp -v -i -s:..\..\..\..\BATCH\ftpMotorCPY.txt 1>..\..\..\..\BATCH\ftpMotorCPY_log.txt 2>..\..\..\..\BATCH\ftpMotorCPY_err.txt
rename * *.cpy
pause


set program_path="E:\Program Files\CAST\8.2\CAST-MS-cli.exe"
set profile=motor
set ver="Dec2017"
set baseline_ver="Set2017"
set date_ver=20171212

rem set list="Motor Mainframe","Motor Core","FlexDA","IncassoDA","DuplicatiDA","NGRA2013","FastQuoteAU_AD","DichiarazioniDA","GestioneAnnullamentiDA","GestioneClientiPPU_DA","GestioneDocumentaleWS","GestioneLibriMatricolaDA","GestionePolizzeAperteDA","GestioneRevocheDA","MicrostockDA","MonitorQualitaDati","RisanamentoDA","ToolTrattativeDA","WSPromoFQ","WSToolTrattative"

rem set list="Motor Core","FlexDA","IncassoDA","DuplicatiDA","NGRA2013","FastQuoteAU_AD","DichiarazioniDA","GestioneAnnullamentiDA","GestioneClientiPPU_DA","GestioneDocumentaleWS","GestioneLibriMatricolaDA","GestionePolizzeAperteDA","GestioneRevocheDA","MicrostockDA","MonitorQualitaDati","RisanamentoDA","ToolTrattativeDA","WSPromoFQ","WSToolTrattative"

set list="GestioneClientiPPU_DA","GestioneDocumentaleWS","GestioneLibriMatricolaDA","GestionePolizzeAperteDA","GestioneRevocheDA","MicrostockDA","MonitorQualitaDati","RisanamentoDA","ToolTrattativeDA","WSPromoFQ","WSToolTrattative"

for %%i in (%list%) do (
 %program_path% AutomateDelivery -connectionProfile %profile% -version %ver% -fromVersion %baseline_ver% -date %date_ver% -appli %%i -logFilePath "I:\CENTRALIZED_LOGS\AutomateDelivery %%~i %date_ver%.txt" 
 if ERRORLEVEL==0 ( %program_path% GenerateSnapshot -connectionProfile %profile% -snapshot %ver% -captureDate %date_ver% -version %ver% -appli %%i -logFilePath "I:\CENTRALIZED_LOGS\%%~i %date_ver%.txt" )
)

pause

for %%i in (%list%) do (
 %program_path% GenerateSnapshot -connectionProfile %profile% -snapshot %ver% -captureDate %date_ver% -version %ver% -appli %%i -logFilePath "I:\CENTRALIZED_LOGS\%%~i %date_ver%.txt" 
)

pause

:to_run

set profile=motor
set ver="Dec2017"
set baseline_ver="Set2017"
set date_ver=20171212

set program_path=E:\temp\com.castsoftware.uc.gap.0.1.4\

set list="Motor Mainframe"

for %%i in (%list%) do (
 "%program_path%GAP-CLI.exe" -a %%i -s %ver% -d %date_ver% -c violations -v 200 -l "I:\CENTRALIZED_LOGS\GAP\GAP %%~i %date_ver%.txt" -e "%program_path%MainframeExclusions.xml" -o AED -m replace --Host 192.168.64.130 --Port 2280 --User operator --Pw CastAIP --Central motor_central --PopSize 800 
)

goto the_end

set list="Motor Core","GestioneAnnullamentiDA","GestioneLibriMatricolaDA","ToolTrattativeDA"


for %%i in (%list%) do (
 "%program_path%GAP-CLI.exe" -a %%i -s %ver% -d %date_ver% -c violations -v 200 -l "I:\CENTRALIZED_LOGS\GAP\GAP %%~i %date_ver%.txt" -e "%program_path%DotNetExclusions.xml" -o AED -m replace --Host 192.168.64.130 --Port 2280 --User operator --Pw CastAIP --Central motor_central --PopSize 800
)



set list="FlexDA","IncassoDA","DuplicatiDA","NGRA2013","FastQuoteAU_AD","DichiarazioniDA","GestioneClientiPPU_DA","GestioneDocumentaleWS","GestionePolizzeAperteDA","GestioneRevocheDA","MicrostockDA","MonitorQualitaDati","RisanamentoDA","WSPromoFQ","WSToolTrattative"

for %%i in (%list%) do (
 "%program_path%GAP-CLI.exe" -a %%i -s %ver% -d %date_ver% -c violations -v 50 -l "I:\CENTRALIZED_LOGS\GAP\GAP %%~i %date_ver%.txt" -e "%program_path%DotNetExclusions.xml" -o AED -m replace --Host 192.168.64.130 --Port 2280 --User operator --Pw CastAIP --Central motor_central --PopSize 200
)

:the_end

pause
