## Vision Code
'''
 detectBlock:
 INPUT: img is n by n by 3 RGB image which has qwirkle blocks and letters to
        identify
 OUTPUT: out is a numBlocks x 5 array containing
           block centroid X (pixel coord)
           block centroid Y (pixel coord)
           block orientation (from -pi/4 to pi/4)
           block type (0 is letter, 1 is shape block)
           block reachable status (0 is unreachable, 1 is in range)
'''
