# OCR Document Layout Detection API

[![FastAPI](https://img.shields.io/badge/FastAPI-0.121.0-009688)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/Python-3.13.2-blue)](https://www.python.org/)
[![PaddleOCR](https://img.shields.io/badge/PaddleOCR-3.3.1-orange)](https://github.com/PaddlePaddle/PaddleOCR)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Fast and efficient document layout detection and text extraction using YOLO object detection and multiple OCR backends.

---

## Quick Start (TL;DR)

Copy-paste these lines to get started instantly:

```bash
git clone <your-repo-url>
cd ocr-api
conda env create -f environment.yml
conda activate ocr
# Create .env file with your GEMINI_API_KEY
make dev
```

Now open http://localhost:8000/docs and you're in 🚀

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Make Help](#make-help)
6. [API Endpoints](#api-endpoints)
7. [Models](#models)
8. [Configuration](#configuration)
9. [Development](#development)
10. [Performance Considerations](#performance-considerations)
11. [Notes](#notes)

---

## Features

- Document layout detection using DocLayout-YOLO
- Text extraction from detected bounding boxes
- Multiple OCR backend support (PaddleOCR, Gemini Vision)
- Concurrent processing for improved performance
- RESTful API endpoints with automatic documentation
- Thread-safe operations for CV2 processing

---

## Prerequisites

Ensure your development environment is ready:

- Python 3.13.2
- Conda package manager
- Gemini API key (for vision-based OCR)

---

## Installation

### 1. Create Conda Environment

```bash
make envcreate
```

Or manually:

```bash
conda env create -f environment.yml
```

### 2. Activate Environment

```bash
conda activate ocr
```

### 3. Configure Environment Variables

Create a `.env` file in the project root:

```env
GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai/
GEMINI_API_KEY=your_gemini_api_key_here
```

---

## Usage

The Makefile provides the following targets:

### Development Mode

```bash
make dev
```

This starts the server with auto-reload on `http://0.0.0.0:8000`

### Production Mode

```bash
make run
```

This starts the server on `http://0.0.0.0:8080`

### API Documentation

Once the server is running, visit:

- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

---

## Make Help

You can list all available commands with:

```bash
make help
```

Available commands:

```bash
run          Run application
dev          Start FastAPI with uvicorn in development mode
envcreate    Create conda environment from environment.yml
envupdate    Update conda environment from environment.yml
envexport    Export clean environment.yml
lint         Check code formatting
clean        Remove __pycache__
```

### Update Environment

```bash
make envupdate
```

### Export Environment

```bash
make envexport
```

This exports the current environment to `environment.yml`.

---

### Clean Cache Files

```bash
make clean
```

This removes:

- `__pycache__` directories
- `.pytest_cache` directories
- Build artifacts

---

## API Endpoints

### 1. Extract Content from Image

**Endpoint:** `POST /predict/content`

Extracts all text content from a single image.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: `file` (image file)

**Response:**
```json
{
  "text": "extracted text content"
}
```

**Example:**
```bash
curl -X POST "http://localhost:8000/predict/content" \
  -F "file=@/path/to/image.png"
```

---

### 2. Detect Bounding Boxes and Extract Content

**Endpoint:** `POST /predict`

Detects document layout bounding boxes and extracts text from each region.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: `files` (one or more image files)

**Response:**
```json
[
  [
    {
      "image_id": 0,
      "bounding_box": {
        "x1": 100,
        "y1": 200,
        "x2": 300,
        "y2": 400
      },
      "content": "extracted text from region"
    }
  ]
]
```

**Example:**
```bash
curl -X POST "http://localhost:8000/predict" \
  -F "files=@/path/to/image1.png" \
  -F "files=@/path/to/image2.png"
```

---

## Models

### DocLayout-YOLO

The project uses DocLayout-YOLO for document layout detection, automatically downloaded from HuggingFace:

- **Repository:** `juliozhao/DocLayout-YOLO-DocStructBench`
- **Model:** `doclayout_yolo_docstructbench_imgsz1024.pt`

### OCR Backends

#### 1. PaddleOCR (Default)

- Fast and efficient OCR
- Supports multiple languages
- No API key required
- Best for general use cases

#### 2. Gemini Vision (Optional)

- Advanced vision-language model
- Requires Gemini API key
- Better accuracy for complex layouts
- Supports Vietnamese text extraction

---

## Configuration

### PaddleOCR Settings

The PaddleOCR model is configured with:

- Document orientation classification: Disabled
- Document unwarping: Disabled
- Text line orientation: Disabled

### YOLO Detection Parameters

- Image size: 1024x1024
- Confidence threshold: 0.2
- IoU threshold: 0.3
- Maximum detections: 1000

### Concurrency

The service uses `ThreadPoolExecutor` with a default of 5 workers for parallel processing of bounding boxes.

---

## Development

### Code Formatting

This project uses:

- **Black** for code formatting (line length: 88)
- **isort** for import sorting
- **flake8** for linting
- **mypy** for type checking

Run all formatters:

```bash
make lint
```

### Adding Dependencies

1. Install package with pip or conda
2. Export environment:

```bash
make envexport
```

---

## Performance Considerations

- The API includes timing information in console output
- Concurrent processing is used for multiple bounding boxes
- Thread-safe operations with lock mechanisms for CV2 operations
- Temporary files are automatically cleaned up after processing
- `max_workers=5` for ThreadPoolExecutor (adjustable in `predict_service.py`)

---

## Notes

- The service uses temporary files for processing uploaded images
- All temporary files are automatically cleaned up after processing
- Thread locks (`cv_lock`) ensure thread-safe operations for OpenCV
- The API includes retry mechanism for Gemini API calls (3 retries)
- JSON responses are validated and cleaned before returning
- Error handling is comprehensive with detailed logging

### Error Handling

The API includes:

- Validation errors for missing environment variables
- Exception handling for file processing
- Retry mechanism for vision model API calls (3 retries)
- JSON parsing validation
- Detailed error messages in console output