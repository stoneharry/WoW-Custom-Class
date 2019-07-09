FADE_IN_TIME = 2;

function TrialConvert_OnLoad()
	this:SetSequence(0);
	this:SetCamera(0);
end

function TrialConvert_OnShow()
	-- CurrentGlueMusic = GlueBackgroundMusic[GetClientExpansionLevel()];
	-- Set BC logo
	-- SetLogo( GetClientExpansionLevel() );

	TrialConvertTitle:Show();
	TrialConvertText:Show();
	TrialConvertRestartButton:Show();
	TrialConvertRestartButton:Enable();
end

function TrialConvert_OnKeyDown()
	if ( arg1 == "ENTER" ) then
		if ( TrialConvertRestartButton:IsShown() ) then
			TrialConvert_Restart();
		end
	elseif ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function TrialConvert_OnEvent()

end

function TrialConvert_Restart()
	TrialConvertRestartButton:Disable();
	PlaySound("gsTitleQuit");
	QuitGameAndRunLauncher();
end