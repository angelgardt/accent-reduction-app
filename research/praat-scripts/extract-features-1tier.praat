# Form definition
form Extract Features
	word Subj subj
	word Filename 0-0
endform

# Extract the names of the Praat objects
thisSound$ = selected$("Sound")
thisTextGrid$ = selected$("TextGrid")

# Extract the number of intervals in the phoneme tier
select TextGrid 'thisTextGrid$'
numberOfPhonemes = Get number of intervals: 1

# Create the Formant Object
select Sound 'thisSound$'
To Formant (burg)... 0 5 5500 0.025 30

# make a Pitch object
select Sound 'thisSound$'
To Pitch... 0.001 75 500

# make an Intensity object
select Sound 'thisSound$'
To Intensity... 75 0.001

# Create the output file and write the first line
outputPath$ = "/Users/antonangelgardt/accent-reduction-app/data/features/" + subj$ + "/" + filename$ + ".csv"
writeFileLine: "'outputPath$'", "numphoneme,phoneme,stress,duration,timef,f0,f0max,f0min,f1,f2,f3,intensity, intensitymax"


for thisInterval from 1 to numberOfPhonemes

    # Get the label of the interval
    select TextGrid 'thisTextGrid$'
    thisPhoneme$ = Get label of interval: 1, thisInterval
  
    # Find the midpoint
    start = Get start point: 1, thisInterval
    end   = Get end point:   1, thisInterval
    duration = end - start
    midpoint = start + duration / 2
	# set middle 60% start and end
	midstart = start + (0.2 * duration)
	midend = end - (0.2 * duration)
	
	writeInfoLine: "Extracting formants..."

    # Extract formant measurements
    select Formant 'thisSound$'
    f1 = Get value at time... 1 midpoint Hertz Linear
    f2 = Get value at time... 2 midpoint Hertz Linear
    f3 = Get value at time... 3 midpoint Hertz Linear

	writeInfoLine: "Extracting intensity..."
	
	# Extract intensity
	select Intensity 'thisSound$'

	# get the mean intencity for middle 60% span
	meanIntensity = Get mean... midstart midend energy

	# get the max intensity
	maxIntensity = Get maximum... start end Cubic

	writeInfoLine: "Extracting pitch..."
	
	# Extract pitch
	select Pitch 'thisSound$'

	# get the mean pitch for middle 60% span
	pitch = Get mean... midstart midend Hertz
	if pitch = undefined
		pitch = -1
	endif

	# get max pitch in span
	maxPitch = Get maximum... start end Hertz None
	if maxPitch = undefined
		maxPitch = -1
	endif

	# get max pitch in span
	minPitch = Get minimum... start end Hertz None
	if minPitch = undefined
		minPitch = -1
	endif

	
	# Save to a spreadsheet
    appendFileLine: "'outputPath$'",
					...thisInterval, ",",
					...thisPhoneme$, ",",
					...duration, ",",
					...midpoint, ",",
					...pitch, ",",
					...maxPitch, ",",
					...minPitch, ",",
					...f1, ",", 
					...f2, ",", 
					...f3, ",",
					...meanIntensity, ",",
					...maxIntensity

endfor


appendInfoLine: newline$, newline$, "Whoo-hoo! It didn't crash!"