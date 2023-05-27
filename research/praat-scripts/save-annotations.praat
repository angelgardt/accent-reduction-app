# Form definition
form SaveAnnotations
	word Subj subj
endform

numberOfSelectedSounds = numberOfSelected("Sound")
numberOfSelectedTextGrid = numberOfSelected("TextGrid")

directory$ = "/Users/antonangelgardt/accent-reduction-app/data/recs/"

appendInfoLine: "Assign an object number to each annotation"

# Assign an object number to each annotation
for thisSelectedTextGrid to numberOfSelectedTextGrid
	textgrid'thisSelectedTextGrid' = selected("TextGrid", thisSelectedTextGrid)
endfor

appendInfoLine: "Assigned"

appendInfoLine: "Loop through the annotations"

# Loop through the annotations
for thisTextGrid from 1 to numberOfSelectedTextGrid
    select textgrid'thisTextGrid'
	name$ = selected$("TextGrid")

	# Old style of Praat coding, but it still works
	do ("Save as text file...", directory$ + subj$ + "/annotation/" + name$ + ".TextGrid")

endfor

appendInfoLine: "Looped"

appendInfoLine: newline$, newline$, "Whoo-hoo! It didn't crash!"