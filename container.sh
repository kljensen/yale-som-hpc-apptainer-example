#!/bin/sh
# Simple script to build and run AI code assistant container
# Usage: ./container.sh [build|shell|test|clean]

set -e

SIF_IMAGE="dev/bookworm.sif"
DEF_FILE="dev/bookworm.def"

# Load apptainer module if not available
load_apptainer() {
    if ! command -v apptainer >/dev/null 2>&1; then
        module load apptainer/1.4.1-nkna
    fi
}

# Build the container
build() {
    echo "Building container from $DEF_FILE..."
    mkdir -p dev
    load_apptainer
    apptainer build "$SIF_IMAGE" "$DEF_FILE"
    echo "Build complete: $SIF_IMAGE"
}

# Start interactive shell in container via SLURM
shell() {
    load_apptainer
    if [ ! -f "$SIF_IMAGE" ]; then
        echo "Error: Container $SIF_IMAGE not found. Run './container.sh build' first."
        exit 1
    fi
    echo "Requesting SLURM resources: 4 CPUs, 4GB RAM..."
    srun --cpus-per-task=4 --mem=4G --pty \
        apptainer shell \
            --bind "$PWD:/workspace" \
            --bind "$HOME" \
            --pwd /workspace \
            "$SIF_IMAGE"
}

# Clean up container image
clean() {
    if [ -f "$SIF_IMAGE" ]; then
        rm -f "$SIF_IMAGE"
        echo "Removed $SIF_IMAGE"
    else
        echo "Nothing to clean: $SIF_IMAGE does not exist"
    fi
}

# Show usage
usage() {
    cat << EOF
Usage: ./container.sh [COMMAND]

Commands:
    build   Build the container image
    shell   Start interactive shell in container
    clean   Remove the container image
    help    Show this help message

Examples:
    ./container.sh build    # Build the container
    ./container.sh shell    # Start a shell inside the container
EOF
}

# Main command dispatcher
case "${1:-help}" in
    build)
        build
        ;;
    shell)
        shell
        ;;
    test)
        test
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        usage
        exit 1
        ;;
esac
