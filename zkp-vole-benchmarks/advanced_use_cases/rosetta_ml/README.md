# Making Rosetta Environment

## 📖 About This Module
We tested the basic building blocks (Matrices and SHA), but to demonstrate the massive scalability of the VOLE family, we included the Rosetta architecture in this repository. It uses `emp-zk` in the backend to prove, in Zero-Knowledge, the inference of a ResNet101 network with millions of parameters, something unthinkable for a traditional SNARK.

### 🗂️ File Structure & Purpose
* **`Dockerfile`**: Installs a specific (and older) AI environment (`tensorflow==1.14.0` and `numpy==1.16.4`). Then, it downloads the Rosetta framework and compiles it with the Zero-Knowledge backend enabled.
* **`Dockerfile2`**: Takes the base image and injects a `checkpoint` folder. In Machine Learning, "checkpoints" are the already trained "brains" of the neural networks (the model weights).
* **`docker-compose-train.yaml`**: Trains a massive Neural Network (ResNet101) from scratch using images from the CIFAR-10 dataset (photos of dogs, cats, cars, etc.).
* **`docker-compose-plain-predict.yaml`**: Tests the neural network "normally" (in plaintext, without cryptography) to verify its prediction accuracy.
* **`docker-compose-zk-predict.yaml`**: Where the magic happens! Runs the ResNet101 neural network to make predictions on images, but entirely within a Zero-Knowledge environment.

---

## Clone Repo
```bash
git clone [https://github.com/nickshey/rosetta-env.git](https://github.com/nickshey/rosetta-env.git)

## Clone Repo
```
git clone https://github.com/nickshey/rosetta-env.git
```

## Build Image
```
docker build -t rosetta .
```

## Enter Image
```
docker run -t rosetta
```

## Train ResNet101
```
docker-compose up -f docker-compose-train.yaml
```

## Build and Train
```
docker build -t rosetta .; docker-compose -f docker-compose-train.yaml up
```

## Build Plaintext Testing Image and Run
```
docker build -f Dockerfile2 . -t rosetta:0.1; docker-compose -f docker-compose-plain-predict.yaml up
```

## Build ZK Testing Image and Run
```
docker build -f Dockerfile2 . -t rosetta:0.1; docker-compose -f docker-compose-zk-predict.yaml up
```