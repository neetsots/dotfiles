function manpdf
	for i in $argv
		man -t $i 2> /dev/null | open -f -a /Applications/Preview.app/ 
	end
end

