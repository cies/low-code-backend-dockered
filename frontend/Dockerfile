FROM node:latest
EXPOSE 3000
WORKDIR /frontend
COPY package-lock.json package.json ./
RUN npm install --no-progress --ignore-optional
RUN chmod -R 777 /home/node /root
CMD npm run dev
