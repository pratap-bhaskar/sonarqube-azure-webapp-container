FROM sonarqube:7.0-alpine
COPY entrypoint.sh ./bin/
RUN chmod +x ./bin/entrypoint.sh
EXPOSE 9000
ENTRYPOINT ["./bin/entrypoint.sh"]
