FROM pandeiro/lein:latest

EXPOSE 80

WORKDIR /app
COPY . /app
# ENTRYPOINT ["/bin/bash"]

RUN echo | lein upgrade
RUN lein deps
ENTRYPOINT ["/usr/bin/lein" , "run" , "ednonlineeditor.shell"]

# Afterwards, run with:
# docker run -P -it twashing/ednonlineeditor:latest 
# docker run -P -it twashing/ednonlineeditor:latest lein run ednonlineeditor.shell