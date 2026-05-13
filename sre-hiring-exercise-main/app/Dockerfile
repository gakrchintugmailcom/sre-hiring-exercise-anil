FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV PORT=8080
EXPOSE 8080

# TODO: this user setup is incomplete, fix it as part of the exercise
USER root

CMD ["python", "app.py"]
