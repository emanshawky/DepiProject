FROM python:3.10-slim
RUN pip install --upgrade pip && pip install flask
RUN mkdir -p /opt/source-code
COPY . /opt/source-code
ENV FLASK_APP=/opt/source-code/app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV DB_PATH=/flask-data
RUN mkdir -p /flask-data
WORKDIR /opt/source-code
EXPOSE 5000
RUN chmod +x entrypoint.sh
COPY entrypoint.sh /opt/source-code
ENTRYPOINT ["/opt/source-code/entrypoint.sh"]