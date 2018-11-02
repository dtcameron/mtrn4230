## Vision Code
'  function blockProperties = detectBlock(img)
  Used for image processing of qwirkle blocks, will differentiate between letter and shape blocks
      INPUT img: Takes in an 1600x1200x3 RGB image
      OUTPUT blockProperties: A n-by-5 array with n qwirkle blocks detected, with properties (in columns):
                              centroidX - X coord of centroid (pixel coord)
                              centroidY - Y coord of centroid (pixel coord)
                              orientation - block angle (from -pi/4 to pi/4)
                              type - indicated type (0 for letter, 1 for shape)
                              reachability - block reachability, depending if in reach of robot (false or true (0 or 1)) '

