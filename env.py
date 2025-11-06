import os

from dotenv import load_dotenv
from pydantic import BaseModel, Field, ValidationError

load_dotenv()


class EnvSchema(BaseModel):
    GEMINI_BASE_URL: str = Field(..., description="Base URL for Gemini API")
    GEMINI_API_KEY: str = Field(..., description="Gemini API Key")


def load_env() -> EnvSchema:
    try:
        return EnvSchema(
            GEMINI_BASE_URL=os.getenv("GEMINI_BASE_URL", ""),
            GEMINI_API_KEY=os.getenv("GEMINI_API_KEY", ""),
        )
    except ValidationError as err:
        raise RuntimeError("Missing or invalid environment variables") from err


env = load_env()
