from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Survey App API"
    database_url: str = "mysql+pymysql://root:password@localhost:3306/survey_db"
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24

    class Config:
        env_file = ".env"


settings = Settings()
