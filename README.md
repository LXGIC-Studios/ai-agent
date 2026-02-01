# ai-agent

[![npm version](https://img.shields.io/npm/v/ai-agent.svg)](https://www.npmjs.com/package/ai-agent)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue.svg)](https://www.typescriptlang.org/)

AI agent framework scaffolding. ReAct, tool-use, planning agents. OpenAI, Anthropic, LangChain compatible.

## Quick Start

```bash
# Run demo agent
npx ai-agent demo "What is 25 * 4?"

# Generate agent scaffolding
npx ai-agent init
```

## Features

- 🤖 **ReAct agents** - Reason + Act loop
- 🔧 **Tool use** - Define custom tools
- 📋 **Zod schemas** - Type-safe parameters
- 🔄 **Iterative** - Multi-step reasoning

## Installation

```bash
npx ai-agent demo "task"
npm install ai-agent
```

## CLI Usage

```bash
# Demo with built-in tools
npx ai-agent demo "Calculate 15% of 200"
npx ai-agent demo --verbose

# Interactive mode
npx ai-agent demo

# Generate scaffolding
npx ai-agent init
npx ai-agent init --type react
```

## Programmatic Usage

```typescript
import {
  createAgent,
  defineTool,
  calculatorTool,
} from 'ai-agent';
import { z } from 'zod';

// Create agent with tools
const agent = createAgent({
  name: 'MyAgent',
  tools: [calculatorTool],
  verbose: true,
});

// Define custom tool
const weatherTool = defineTool(
  'get_weather',
  'Get weather for a location',
  z.object({ location: z.string() }),
  async ({ location }) => {
    return `Weather in ${location}: Sunny, 72°F`;
  }
);

agent.addTool(weatherTool);

// Run agent
const result = await agent.run('What is 25 * 4?');
console.log(result.answer);
console.log(result.steps);
```

## Agent Types

| Type | Use Case |
|------|----------|
| ReAct | Multi-step reasoning with tools |
| Simple | Single response, no tools |
| Planning | Plan then execute |

## Part of the LXGIC Dev Toolkit

One of 110+ free developer tools from LXGIC Studios.

- GitHub: https://github.com/lxgicstudios
- Twitter: https://x.com/lxgicstudios
- Website: https://lxgicstudios.com

## License

MIT. Free forever.
