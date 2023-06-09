# AI Playground Desktop Client
Language Model playground to access languages models like StableLM, ChatGPT, and more.

Language Models supported:

* stablelm-tuned-alpha-7b
* llama-7b
* flan-t5-xl
* dolly-v2-12b
* oasst-sft-1-pythia-12b
* gpt-j-6b

* gpt-4 - OpenAI
* gpt-4-0314 - OpenAI
* gpt-4-32k - OpenAI
* gpt-4-32k-0314 - OpenAI
* gpt-3.5-turbo - OpenAI
* gpt-3.5-turbo-0301 - OpenAI
* text-davinci-003 - OpenAI
* text-davinci-002 - OpenAI
* code-davinci-002 - OpenAI
* text-curie-001 - OpenAI
* text-babbage-001 - OpenAI
* text-ada-001 - OpenAI
* davinci - OpenAI
* curie - OpenAI
* babbage - OpenAI
* ada - OpenAI
* and more!

Copy a FMX TLabel of a response directly from the client into the Delphi IDE!

Built with [Delphi](https://www.embarcadero.com/products/delphi/) using the FireMonkey framework this client works on Windows, macOS, and Linux (and maybe Android+iOS) with a single codebase and single UI. At the moment it is specifically set up for Windows.

It features a REST integration with Replicate.com and OpenAI.com within the client. You need to sign up for an API key each service to access th functionality. Replicate models can be run in the cloud or locally via docker.

```
docker run -d -p 5000:5000 --gpus=all r8.im/replicate/vicuna-13b@sha256:6282abe6a492de4145d7bb601023762212f9ddbbe78278bd6771c8b3b2f2a13b
curl http://localhost:5000/predictions -X POST -H "Content-Type: application/json" \
  -d '{"input": {
    "prompt": "...",
    "max_length": "...",
    "temperature": "...",
    "top_p": "...",
    "repetition_penalty": "...",
    "seed": "...",
    "debug": "..."
  }}'
```

# AI Playground Desktop client Screeshot on Windows
![AI Playground Desktop client on Windows](/screenshot.jpg)

Requires [Skia4Delphi](https://github.com/skia4delphi/skia4delphi) to compile.

Other Delphi AI clients:

[AI Code Translator](https://github.com/FMXExpress/AI-Code-Translator)

[Stable Diffusion Desktop Client](https://github.com/FMXExpress/Stable-Diffusion-Desktop-Client)

[Song Writer AI](https://github.com/FMXExpress/Song-Writer-AI)

[Stable Diffusion Text To Image Prompts](https://github.com/FMXExpress/Stable-Diffusion-Text-To-Image-Prompts)

[Generative AI Prompts](https://github.com/FMXExpress/Generative-AI-Prompts)

[Dreambooth Desktop Client](https://github.com/FMXExpress/DreamBooth-Desktop-Client)

[Text To Vector Desktop Client](https://github.com/FMXExpress/Text-To-Vector-Desktop-Client)
