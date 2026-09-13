# Dependencies

## Matlab toolboxes

No specific Matlab version is recorded. The `.m` scripts use functions
from the following toolboxes:

- **Image Processing Toolbox** -- `activecontour`, `dicomread`/
  `dicominfo`, and general image I/O/filtering used throughout.
- **Computer Vision Toolbox** -- `detectSURFFeatures`, `extractFeatures`,
  `bagOfFeatures`, and related SIFT/SURF/bag-of-visual-words functions
  (`BoW_SURF.m`, `BoVWtest.m`, `SIFTtest.m`, `matchSIFT.m`,
  `count2011Sift.m`).
- **Deep Learning Toolbox** -- `trainNetwork`, `layerGraph`,
  `trainingOptions`, `imageDatastore`. `Training_DeTraC.m` additionally
  requires the **Deep Learning Toolbox Model for ResNet-18 Network**
  add-on (`resnet18`); `Training_original_classes.m` requires the
  **Deep Learning Toolbox Model for AlexNet Network** add-on (`alexnet`).

Both training scripts expect an `imageDatastore` folder (`dataset_A` /
`dataset_B`) of labeled training images that is not included in this
repository.

## Jupyter notebook (`DeTraC_model.ipynb`)

A separate Python 3 environment with no `requirements.txt` included. The
notebook imports: `opencv-python` (`cv2`), `pandas`, `numpy`,
`matplotlib`, `scikit-learn`, `scikit-image`, `mlxtend`,
`tensorflow`/`keras` (uses `ResNet50` from
`tensorflow.keras.applications`).

## Hardcoded paths

Several `.m` files contain hardcoded absolute paths to the original
author's machine (e.g. `A:\Amydis\...`). Active (non-commented)
instances are flagged with a `% EDIT:` comment directly above them --
update these before running a script.
