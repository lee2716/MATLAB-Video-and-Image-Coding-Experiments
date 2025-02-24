# MATLAB Video and Image Coding Experiments

## Overview
This repository contains MATLAB implementations for experiments related to video and image coding, focusing on JPEG compression and block-matching motion estimation.

## Features

### 1. JPEG Encoding & Decoding
- Implemented the JPEG compression pipeline:
  - 8×8 Discrete Cosine Transform (DCT)
  - Quantization
  - Zigzag Scanning
  - Entropy Encoding (Huffman Coding)
  - Decoding and Reconstruction
- Evaluated rate-distortion performance using PSNR vs. bit rate curves.

### 2. Block-Matching Motion Estimation
- Implemented motion estimation using block-matching algorithms:
  - Full Search (Exhaustive Search)
  - Three-Step Search (TSS) & New Three-Step Search (NTSS)
  - Four-Step Search (FSS)
  - Diamond Search (DS)
- Compared different motion estimation strategies based on PSNR and computational complexity.

