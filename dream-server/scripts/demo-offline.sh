#!/bin/bash
# Dream Server Offline Demo Mode
# Demonstrates what each feature WOULD do without running services
# Useful for sales demos, documentation screenshots, presentations
# Usage: ./scripts/demo-offline.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Simulated typing effect
type_text() {
    local text="$1"
    local delay="${2:-0.02}"
    for ((i=0; i<${#text}; i++)); do
        printf '%s' "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# Simulated streaming response
stream_text() {
    local text="$1"
    local delay="${2:-0.01}"
    for word in $text; do
        printf '%s ' "$word"
        sleep "$delay"
    done
    echo ""
}

clear_screen() {
    printf "\033[2J\033[H"
}

pause() {
    echo ""
    echo -e "${DIM}Press Enter to continue...${NC}"
    read -r
}

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—${NC}"
    echo -e "${BOLD}${CYAN}â•‘          Dream Server â€” Offline Demo Mode                   â•‘${NC}"
    echo -e "${BOLD}${CYAN}â•‘          ${DIM}(No GPU/services required)${BOLD}${CYAN}                         â•‘${NC}"
    echo -e "${BOLD}${CYAN}â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•${NC}"
    echo ""
}

print_menu() {
    echo -e "${BOLD}Select a demo:${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} Chat with AI             ${DIM}â€” See the chat experience${NC}"
    echo -e "  ${CYAN}[2]${NC} Voice-to-Voice           ${DIM}â€” Speak to your AI${NC}"
    echo -e "  ${CYAN}[3]${NC} Document Q&A (RAG)       ${DIM}â€” Ask questions about docs${NC}"
    echo -e "  ${CYAN}[4]${NC} Code Assistant            ${DIM}â€” AI code review${NC}"
    echo -e "  ${CYAN}[5]${NC} Hardware Detection        ${DIM}â€” What the installer sees${NC}"
    echo -e "  ${CYAN}[6]${NC} System Overview           ${DIM}â€” Full stack walkthrough${NC}"
    echo -e "  ${CYAN}[A]${NC} Run All Demos             ${DIM}â€” Full showcase${NC}"
    echo -e "  ${CYAN}[Q]${NC} Quit"
    echo ""
    echo -ne "${BOLD}Select: ${NC}"
}

# â”€â”€ Demo 1: Chat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
demo_chat() {
    clear_screen
    echo -e "${BOLD}${MAGENTA}Demo: Chat with AI${NC}"
    echo -e "${DIM}â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”${NC}"
    echo ""
    echo -e "${DIM}[Connected to llama-server â†’ local GGUF model]${NC}"
    echo -e "${DIM}[API: http://localhost:8080/v1/chat/completions]${NC}"
    echo ""

    echo -ne "${GREEN}You: ${NC}"
    type_text "What can Dream Server do?" 0.04

    echo -ne "${CYAN}AI:  ${NC}"
    stream_text "Dream Server is your complete local AI stack. I can help you with:" 0.03
    echo ""
    stream_text "  1. Natural language chat (that's me!)" 0.02
    stream_text "  2. Voice conversations â€” speak to me and I'll speak back" 0.02
    stream_text "  3. Document analysis â€” upload docs and ask questions" 0.02
    stream_text "  4. Code assistance â€” explain, improve, or debug your code" 0.02
    stream_text "  5. Workflow automation â€” chain AI tasks together with n8n" 0.02
    echo ""
    stream_text "Everything runs locally on your hardware. No cloud, no API fees, no data leaving your network." 0.02

    echo ""
    echo -e "${DIM}â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€${NC}"
    echo -ne "${GREEN}You: ${NC}"
    type_text "How fast is inference?" 0.04

    echo -ne "${CYAN}AI:  ${NC}"
    stream_text "On a single RTX 4090 with the 32B AWQ model, you can expect:" 0.03
    echo ""
    stream_text "  â€¢ Time to first token: ~200ms" 0.02
    stream_text "  â€¢ Generation speed: 30-50 tokens/sec" 0.02
    stream_text "  â€¢ Throughput: handles multiple concurrent users" 0.02
    echo ""
    stream_text "llama-server uses continuous batching for efficient memory management, so you get near-optimal GPU utilization." 0.02

    pause
}

# â”€â”€ Demo 2: Voice â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
demo_voice() {
    clear_screen
    echo -e "${BOLD}${MAGENTA}Demo: Voice-to-Voice${NC}"
    echo -e "${DIM}â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”${NC}"
    echo ""
    echo -e "${DIM}[Pipeline: Whisper STT â†’ llama-server â†’ Kokoro TTS]${NC}"
    echo ""

    echo -e "${YELLOW}Recording...${NC} ${DIM}(5 seconds)${NC}"
    for i in 5 4 3 2 1; do
        echo -ne "\r  ${BOLD}${i}s${NC} remaining â–“â–“â–“"
        printf 'â–“%.0s' $(seq 1 $((6-i)))
        printf 'â–‘%.0s' $(seq 1 $((i-1)))
        sleep 0.5
    done
    echo -e "\r  ${GREEN}âœ“ Recorded${NC}                    "
    echo ""

    echo -e "${CYAN}Transcribing with Whisper...${NC}"
    sleep 0.8
    echo -e "  ${GREEN}âœ“${NC} \"Tell me about the weather today\""
    echo ""

    echo -e "${CYAN}Generating response with llama-server...${NC}"
    sleep 0.6
    echo -ne "  ${GREEN}âœ“${NC} "
    stream_text "I don't have real-time weather data since I run locally, but I can help you set up a workflow that fetches weather from a free API and reads it to you every morning!" 0.02
    echo ""

    echo -e "${CYAN}Synthesizing speech with OpenTTS...${NC}"
    sleep 0.5
    echo -e "  ${GREEN}âœ“${NC} Generated audio (2.3 seconds, en_US-lessac-medium)"
    echo ""

    echo -e "${GREEN}â–¶ Playing response...${NC}"
    echo -e "  ${DIM}â™ª â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘ 2.3s${NC}"
    sleep 1

    echo ""
    echo -e "${BOLD}curl command:${NC}"
    echo -e "${DIM}  curl -X POST http://localhost:5678/webhook/voice-chat \\${NC}"
    echo -e "${DIM}    -F \"audio=@recording.wav\" -o response.wav${NC}"

    pause
}

# â”€â”€ Demo 3: RAG â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
demo_rag() {
    clear_screen
    echo -e "${BOLD}${MAGENTA}Demo: Document Q&A (RAG)${NC}"
    echo -e "${DIM}â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”${NC}"
    echo ""
    echo -e "${DIM}[Pipeline: Upload â†’ Chunk â†’ Embed â†’ Qdrant â†’ Query â†’ LLM]${NC}"
    echo ""

    echo -e "${CYAN}Step 1: Uploading document...${NC}"
    sleep 0.3
    echo "  File: company-handbook.pdf (42 pages)"
    echo ""

    echo -e "${CYAN}Step 2: Chunking text...${NC}"
    sleep 0.3
    echo "  Created 187 chunks (500 chars, 100 overlap)"
    echo ""

    echo -e "${CYAN}Step 3: Generating embeddings...${NC}"
    sleep 0.5
    echo "  Model: BAAI/bge-base-en-v1.5 (768 dimensions)"
    echo -e "  ${GREEN}âœ“${NC} 187/187 chunks embedded"
    echo ""

    echo -e "${CYAN}Step 4: Stored in Qdrant...${NC}"
    sleep 0.3
    echo "  Collection: dream-docs (187 vectors)"
    echo ""

    echo -e "${DIM}â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€${NC}"
    echo ""

    echo -ne "${GREEN}Question: ${NC}"
    type_text "What is the PTO policy?" 0.04

    echo -e "${CYAN}Searching...${NC}"
    sleep 0.4
    echo "  Found 3 relevant chunks (similarity: 0.89, 0.84, 0.81)"
    echo ""

    echo -ne "${CYAN}Answer: ${NC}"
    stream_text "According to the company handbook, the PTO policy provides:" 0.03
    echo ""
    stream_text "  â€¢ 15 days PTO for new employees (years 1-3)" 0.02
    stream_text "  â€¢ 20 days PTO after 3 years" 0.02
    stream_text "  â€¢ 25 days PTO after 5 years" 0.02
    stream_text "  â€¢ Unused PTO carries over up to 5 days" 0.02
    echo ""
    echo -e "  ${DIM}Source: handbook.pdf, pages 12-13${NC}"

    pause
}

# â”€â”€ Demo 4: Code Assistant â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
demo_code() {
    clear_screen
    echo -e "${BOLD}${MAGENTA}Demo: Code Assistant${NC}"
    echo -e "${DIM}â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”${NC}"
    echo ""
    echo -e "${DIM}[Task: improve | Language: python]${NC}"
    echo ""

    echo -e "${YELLOW}Input:${NC}"
    echo -e "${DIM}  def read_config(path):${NC}"
    echo -e "${DIM}      f = open(path, 'r')${NC}"
    echo -e "${DIM}      data = json.load(f)${NC}"
    echo -e "${DIM}      return data${NC}"
    echo ""

    echo -e "${CYAN}Analyzing...${NC}"
    sleep 0.8
    echo ""

    echo -e "${GREEN}Improved:${NC}"
    echo ""
    stream_text "  def read_config(path: str) -> dict:" 0.02
    stream_text "      \"\"\"Read configuration from JSON file.\"\"\"" 0.02
    stream_text "      with open(path, 'r') as f:" 0.02
    stream_text "          return json.load(f)" 0.02
    echo ""
    echo -e "${BOLD}Changes:${NC}"
    stream_text "  1. Added context manager (with) â€” file is always closed, even on error" 0.02
    stream_text "  2. Added type hints for clarity" 0.02
    stream_text "  3. Added docstring" 0.02

    echo ""
    echo -e "${BOLD}curl command:${NC}"
    echo -e "${DIM}  curl -X POST http://localhost:5678/webhook/code-assist \\${NC}"
    echo -e "${DIM}    -H 'Content-Type: application/json' \\${NC}"
    echo -e "${DIM}    -d '{\"code\": \"...\", \"task\": \"improve\"}'${NC}"

    pause
}

# â”€â”€ Demo 5: Hardware Detection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
demo_hardware() {
    clear_screen
    echo -e "${BOLD}${MAGENTA}Demo: Hardware Detection${NC}"
    echo -e "${DIM}â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”${NC}"
    echo ""
    echo -e "${DIM}Running: ./scripts/detect-hardware.sh${NC}"
    echo ""

    # Try running real detection, fall back to mock
    if [[ -x "$(dirname "$0")/detect-hardware.sh" ]]; then
        "$(dirname "$0")/detect-hardware.sh" 2>/dev/null || {
            echo -e "${BLUE}â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—${NC}"
            echo -e "${BLUE}â•‘      Dream Server Hardware Detection     â•‘${NC}"
            echo -e "${BLUE}â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•${NC}"
            echo ""
            echo -e "${GREEN}System:${NC}"
            echo "  OS:       linux"
            echo "  CPU:      AMD Ryzen 9 7950X"
            echo "  Cores:    32"
            echo "  RAM:      64GB"
            echo ""
            echo -e "${GREEN}GPU:${NC}"
            echo "  Type:     nvidia"
            echo "  Name:     NVIDIA GeForce RTX 4090"
            echo "  VRAM:     24GB"
            echo ""
            echo -e "${YELLOW}Recommended Tier: T3${NC}"
            echo "  Pro (20-47GB): 32B models, comfortable headroom"
        }
    else
        echo -e "${BLUE}â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—${NC}"
        echo -e "${BLUE}â•‘      Dream Server Hardware Detection     â•‘${NC}"
        echo -e "${BLUE}â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•${NC}"
        echo ""
        echo -e "${GREEN}System:${NC}"
        echo "  OS:       linux"
        echo "  CPU:      AMD Ryzen 9 7950X"
        echo "  Cores:    32"
        echo "  RAM:      64GB"
        echo ""
        echo -e "${GREEN}GPU:${NC}"
        echo "  Type:     nvidia"
        echo "  Name:     NVIDIA GeForce RTX 4090"
        echo "  VRAM:     24GB"
        echo ""
        echo -e "${YELLOW}Recommended Tier: T3${NC}"
        echo "  Pro (20-47GB): 32B models, comfortable headroom"
    fi

    echo ""
    echo -e "${BOLD}The installer uses this to auto-select:${NC}"
    echo "  â€¢ Model:   Qwen/Qwen2.5-32B-Instruct-AWQ"
    echo "  â€¢ Context: 32768 tokens"
    echo "  â€¢ VRAM:    90% utilization"

    pause
}

# â”€â”€ Demo 6: System Overview â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
demo_overview() {
    clear_screen
    echo -e "${BOLD}${MAGENTA}Dream Server â€” System Overview${NC}"
    echo -e "${DIM}â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”${NC}"
    echo ""

    echo -e "${BOLD}Architecture:${NC}"
    echo ""
    echo -e "  ${CYAN}â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”${NC}"
    echo -e "  ${CYAN}â”‚               Open WebUI (:3000)                â”‚${NC}"
    echo -e "  ${CYAN}â”‚           Beautiful chat interface              â”‚${NC}"
    echo -e "  ${CYAN}â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€  â”˜${NC}"
    echo -e "  ${CYAN}                     â”‚${NC}"
    echo -e "  ${CYAN}â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€  â”${NC}"
    echo -e "  ${CYAN}â”‚           llama-server (:8080)                   â”‚${NC}"
    echo -e "  ${CYAN}â”‚     High-performance LLM inference              â”‚${NC}"
    echo -e "  ${CYAN}â”‚     GGUF models â€¢ 30-50 tok/s â€¢ GPU offload     â”‚${NC}"
    echo -e "  ${CYAN}â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€   â”˜${NC}"
    echo -e "  ${CYAN}       â”‚                            â”‚${NC}"
    echo -e "  ${CYAN}â”Œâ”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”              â”Œâ”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”${NC}"
    echo -e "  ${CYAN}â”‚ Whisper STT â”‚              â”‚  OpenTTS TTS  â”‚${NC}"
    echo -e "  ${CYAN}â”‚  (:9000)    â”‚              â”‚  (:8880)   â”‚${NC}"
    echo -e "  ${CYAN}â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜              â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜${NC}"
    echo ""
    echo -e "  ${CYAN}â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”${NC}"
    echo -e "  ${CYAN}â”‚ n8n (:5678) â”‚  â”‚Qdrant(:6333)â”‚  â”‚LiteLLM(:4K) â”‚${NC}"
    echo -e "  ${CYAN}â”‚  Workflows  â”‚  â”‚  Vector DB  â”‚  â”‚ API Gateway â”‚${NC}"
    echo -e "  ${CYAN}â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜${NC}"
    echo ""

    echo -e "${BOLD}One command to install:${NC}"
    echo -e "  ${DIM}curl -fsSL https://get.dreamserver.dev | bash${NC}"
    echo ""
    echo -e "${BOLD}Then:${NC}"
    echo -e "  ${GREEN}âœ“${NC} Chat UI at localhost:3000"
    echo -e "  ${GREEN}âœ“${NC} Voice assistant (speak â†” listen)"
    echo -e "  ${GREEN}âœ“${NC} Document Q&A (upload â†’ ask)"
    echo -e "  ${GREEN}âœ“${NC} Code review (paste â†’ improve)"
    echo -e "  ${GREEN}âœ“${NC} Workflow automation (visual builder)"
    echo ""
    echo -e "${BOLD}All local. No cloud. No API fees. Your data stays yours.${NC}"

    pause
}

# â”€â”€ Run All â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
run_all() {
    demo_chat
    demo_voice
    demo_rag
    demo_code
    demo_hardware
    demo_overview
    echo -e "${GREEN}${BOLD}Demo complete!${NC}"
}

# â”€â”€ Main Loop â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
while true; do
    clear_screen
    print_header
    print_menu

    read -r choice

    case "${choice,,}" in
        1) demo_chat ;;
        2) demo_voice ;;
        3) demo_rag ;;
        4) demo_code ;;
        5) demo_hardware ;;
        6) demo_overview ;;
        a|all) run_all ;;
        q|quit|exit)
            echo ""
            echo -e "${GREEN}Thanks for watching!${NC}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option${NC}"
            sleep 0.5
            ;;
    esac
done
