FROM python:3.10-slim
RUN pip install --upgrade pip && pip install flask
RUN mkdir -p /opt/source-code
COPY . /opt/source-code
WORKDIR /opt/source-code
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8080
ENV DB_PATH=/flask-data
RUN mkdir -p /flask-data
EXPOSE 8080


CMD ["sh", "-c", "python -c 'from app import init_db; init_db()' && flask run"]