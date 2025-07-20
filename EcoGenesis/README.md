# EcoGenesis Protocol

> A decentralized biodiversity tracking system built on Stacks blockchain using Clarity smart contracts.

## Overview

EcoGenesis Protocol enables researchers, conservationists, and citizen scientists to create an immutable, global registry of biodiversity observations. By leveraging blockchain technology, we ensure data integrity, transparency, and decentralized governance of critical ecological information.

## Features

- **🔬 Researcher Verification System** - Multi-tier verification for data quality assurance
- **🌱 Species Registry** - Comprehensive taxonomic database with IUCN conservation status
- **📍 Geospatial Observations** - GPS-validated biodiversity recordings with habitat descriptions
- **✅ Peer Verification** - Community-driven data validation mechanism
- **📊 Analytics Dashboard** - Real-time biodiversity metrics and location-based insights

## Smart Contract Functions

### Public Functions

| Function | Description | Access Level |
|----------|-------------|--------------|
| `register-researcher` | Register as a biodiversity researcher | Anyone |
| `verify-researcher` | Verify researcher credentials | Contract Owner |
| `add-species` | Add new species to the registry | Verified Researchers |
| `record-observation` | Log biodiversity observations with GPS data | Registered Researchers |
| `verify-observation` | Peer-review and verify observations | Verified Researchers |

### Read-Only Functions

- `get-researcher` - Retrieve researcher profile and statistics
- `get-species` - Query species information by ID
- `get-observation` - Fetch observation details
- `get-location-data` - Get aggregated location-based metrics
- `get-contract-stats` - Global platform statistics

## Quick Start

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) installed
- Stacks wallet configured
- Basic understanding of Clarity smart contracts

### Deployment

```bash
# Clone the repository
git clone https://github.com/your-org/biochain-phylogenetic-ledger
cd biochain-phylogenetic-ledger/EcoGenesis

# Check contract syntax
clarinet check

# Run tests
clarinet test

# Deploy to testnet
clarinet publish --testnet
```

### Usage Example

```clarity
;; Register as a researcher
(contract-call? .endemic-species-registry register-researcher 
  "Dr. Jane Smith" 
  "University of Conservation Biology")

;; Add a new species (after verification)
(contract-call? .endemic-species-registry add-species
  "Panthera tigris"
  "Bengal Tiger"
  "Animalia"
  "Endangered")

;; Record an observation
(contract-call? .endemic-species-registry record-observation
  u1                    ;; species-id
  23500000             ;; latitude (23.5°N in micro-degrees)
  90250000             ;; longitude (90.25°E in micro-degrees)
  u3                   ;; population count
  "Dense mangrove forest with tidal influence")
```

## Data Validation

The contract implements comprehensive input validation:

- **Taxonomic Accuracy** - Kingdom validation against accepted taxonomies
- **Geographic Bounds** - GPS coordinates within valid Earth ranges (-90° to 90° lat, -180° to 180° lon)
- **Conservation Status** - IUCN Red List category compliance
- **String Sanitization** - Length limits and non-empty validation
- **Access Controls** - Role-based permissions for data integrity

## Conservation Status Categories

Supported IUCN Red List categories:
- `Extinct`
- `Extinct in Wild`
- `Critically Endangered`
- `Endangered`
- `Vulnerable`
- `Near Threatened`
- `Least Concern`
- `Data Deficient`
- `Not Evaluated`

## Taxonomic Kingdoms

Supported biological kingdoms:
- `Animalia`
- `Plantae`
- `Fungi`
- `Protista`
- `Bacteria`
- `Archaea`

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `ERR-NOT-AUTHORIZED` | Insufficient permissions |
| 101 | `ERR-ALREADY-EXISTS` | Resource already exists |
| 102 | `ERR-NOT-FOUND` | Resource not found |
| 103 | `ERR-INVALID-COORDINATES` | GPS coordinates out of range |
| 104 | `ERR-INVALID-POPULATION` | Population count invalid |
| 105 | `ERR-INVALID-INPUT` | General input validation failure |
| 106 | `ERR-EMPTY-STRING` | Required string is empty |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/endemic-tracking`)
3. Add comprehensive tests for new functionality
4. Ensure `clarinet check` passes without warnings
5. Submit a pull request with detailed description

## Use Cases

- **Conservation Research** - Track endangered species populations over time
- **Citizen Science** - Enable global community participation in biodiversity monitoring
- **Environmental Impact Assessment** - Document ecosystem changes for development projects
- **Academic Research** - Provide immutable data for peer-reviewed studies
- **Policy Making** - Supply verified data for conservation legislation

## Roadmap

- [ ] Integration with IoT sensors for automated data collection
- [ ] Mobile app for field researchers
- [ ] IPFS integration for storing observation images
- [ ] Machine learning models for species identification validation
- [ ] Carbon credit integration for conservation incentives

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

*Built with 🌍 for planetary biodiversity conservation*