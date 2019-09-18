# ASPECT-PRM
# Scripts and parameter files used to accompany the EPSL submitted manuscript. 
 First the sampling_box.prm parameter file is used in ASPECT to produce orthogonal rifting out of which we obtain the 5 My output.
 Then that file is loaded into ParaView where the data is saved into .csv format.
 Then using the output csv, the composition_rotation.m script is run to create an ASPECT-readable composition format output
 This is then input into ASPECT as an ASCII file in the rotation_example.prm file.
