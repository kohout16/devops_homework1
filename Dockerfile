FROM python:3.11-slim
COPY . /app
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt && rm -rf requirements.txt
RUN python test.py -v
EXPOSE 3000
CMD ["python", "my_calculations.py"]
