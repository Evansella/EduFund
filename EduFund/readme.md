# Academic Scholarship Distribution System

A blockchain-powered scholarship distribution system built on the Stacks blockchain using Clarity smart contracts. This system ensures transparency, fairness, and accountability in awarding academic funds to qualified students.

## Overview

The Academic Scholarship Distribution System leverages blockchain technology to create a transparent and immutable record of scholarship awards. University administrators can manage qualified students, distribute scholarship tokens, and maintain a complete audit trail of all transactions.

## Features

### Core Functionality
- **Student Qualification Management**: Add/remove qualified students
- **Bulk Operations**: Efficiently manage multiple students at once
- **Scholarship Distribution**: Automated token distribution to qualified students
- **Transparent Tracking**: Complete audit trail of all scholarship activities
- **Fund Recovery**: Withdrawal of unclaimed scholarships after designated periods

### Security Features
- **Admin-Only Controls**: Critical functions restricted to university administrators
- **Duplicate Prevention**: Students cannot claim scholarships multiple times
- **Fund Verification**: Ensures sufficient funds before distribution
- **Time-locked Withdrawals**: Prevents premature withdrawal of unclaimed funds

## Smart Contract Architecture

### Constants
```clarity
UNIVERSITY-ADMIN          // Contract deployer with administrative privileges
ERROR-* constants         // Comprehensive error handling codes
```

### Data Variables
- `is-program-active`: Controls program availability
- `total-scholarships-awarded`: Tracks total distributed amount
- `scholarship-amount-per-student`: Configurable award amount
- `program-launch-block`: Reference point for time calculations
- `withdrawal-semester-length`: Period before unclaimed funds can be withdrawn

### Data Maps
- `qualified-scholarship-students`: Tracks student eligibility
- `awarded-scholarship-amounts`: Records individual scholarship amounts
- `academic-records`: Maintains audit trail of all activities

## Functions

### Administrative Functions

#### `add-qualified-student(student-address)`
Adds a new student to the qualified recipients list.
- **Access**: University Admin only
- **Parameters**: Student's principal address
- **Returns**: Success confirmation

#### `remove-qualified-student(student-address)`
Removes a student from the qualified recipients list.
- **Access**: University Admin only
- **Parameters**: Student's principal address
- **Returns**: Success confirmation

#### `bulk-add-qualified-students(student-addresses)`
Efficiently adds multiple students (up to 200) to the qualified list.
- **Access**: University Admin only
- **Parameters**: List of student principal addresses
- **Returns**: Success confirmation

#### `update-scholarship-amount(new-amount)`
Updates the scholarship amount per student.
- **Access**: University Admin only
- **Parameters**: New scholarship amount (must be > 0)
- **Returns**: Updated amount

#### `update-withdrawal-period(new-period)`
Updates the withdrawal period for unclaimed scholarships.
- **Access**: University Admin only
- **Parameters**: New period in blocks (must be > 0)
- **Returns**: Updated period

### Student Functions

#### `claim-scholarship-tokens()`
Allows qualified students to claim their scholarship tokens.
- **Access**: Any qualified student
- **Requirements**: 
  - Program must be active
  - Student must be qualified
  - Student must not have already claimed
  - Sufficient funds must be available
- **Returns**: Awarded amount

### Fund Management

#### `withdraw-unclaimed-scholarships()`
Allows admin to withdraw unclaimed scholarships after the withdrawal period.
- **Access**: University Admin only
- **Requirements**: Withdrawal period must have elapsed
- **Returns**: Amount of unclaimed tokens burned

### Read-Only Functions

#### Query Functions
- `get-program-active-status()`: Check if program is active
- `is-student-qualified(student-address)`: Verify student qualification
- `has-student-claimed-scholarship(student-address)`: Check claim status
- `get-student-awarded-amount(student-address)`: Get awarded amount
- `get-total-scholarships-awarded()`: Total distributed scholarships
- `get-scholarship-amount-per-student()`: Current award amount
- `get-withdrawal-period()`: Current withdrawal period
- `get-program-launch-block()`: Program start block
- `get-academic-record(record-id)`: Retrieve audit record

## Token Economics

### Initial Supply
- **Total Tokens**: 1,000,000,000 academic-scholarship-tokens
- **Initial Holder**: University Admin
- **Distribution**: On-demand to qualified students

### Token Flow
1. University Admin receives initial token supply
2. Qualified students claim predetermined amounts
3. Unclaimed tokens can be burned after withdrawal period
4. All transactions are permanently recorded on blockchain

## Deployment Guide

### Prerequisites
- Stacks blockchain development environment
- Clarity CLI tools
- Stacks testnet/mainnet access

### Deployment Steps

1. **Prepare Environment**
   ```bash
   # Install Stacks CLI
   npm install -g @stacks/cli
   
   # Verify installation
   stx --version
   ```

2. **Deploy Contract**
   ```bash
   # Deploy to testnet
   stx deploy_contract scholarship_contract EduFund.clar --testnet
   
   # Deploy to mainnet (when ready)
   stx deploy_contract scholarship_contract EduFund.clar --mainnet
   ```

3. **Initial Configuration**
   ```bash
   # Set scholarship amount (example: 100 tokens)
   stx call_contract_func scholarship_contract update-scholarship-amount 100 --testnet
   
   # Add qualified students
   stx call_contract_func scholarship_contract add-qualified-student [student-address] --testnet
   ```

## Usage Examples

### Adding Students
```clarity
;; Add single student
(contract-call? .scholarship-contract add-qualified-student 'SP1STUDENT123...)

;; Add multiple students
(contract-call? .scholarship-contract bulk-add-qualified-students 
  (list 'SP1STUDENT123... 'SP2STUDENT456... 'SP3STUDENT789...))
```

### Student Claims Scholarship
```clarity
;; Student calls this function
(contract-call? .scholarship-contract claim-scholarship-tokens)
```

### Administrative Updates
```clarity
;; Update scholarship amount to 150 tokens
(contract-call? .scholarship-contract update-scholarship-amount u150)

;; Update withdrawal period to 20000 blocks
(contract-call? .scholarship-contract update-withdrawal-period u20000)
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | ERROR-NOT-UNIVERSITY-ADMIN | Function restricted to admin |
| 101 | ERROR-SCHOLARSHIP-ALREADY-AWARDED | Student already received scholarship |
| 102 | ERROR-STUDENT-NOT-QUALIFIED | Student not in qualified list |
| 103 | ERROR-INSUFFICIENT-SCHOLARSHIP-FUNDS | Not enough tokens available |
| 104 | ERROR-PROGRAM-NOT-ACTIVE | Scholarship program is inactive |
| 105 | ERROR-INVALID-SCHOLARSHIP-AMOUNT | Invalid amount specified |
| 106 | ERROR-WITHDRAWAL-PERIOD-NOT-ENDED | Too early to withdraw unclaimed funds |
| 107 | ERROR-INVALID-STUDENT | Student already exists or invalid |
| 108 | ERROR-INVALID-SEMESTER-PERIOD | Invalid time period specified |

## Security Considerations

### Access Control
- All administrative functions require university admin authentication
- Students can only claim scholarships once
- Fund withdrawals are time-locked

### Data Integrity
- All transactions are immutably recorded
- Comprehensive audit trail through academic records
- Duplicate prevention mechanisms

### Best Practices
1. Regularly backup qualified student lists
2. Monitor scholarship claims and balances
3. Set appropriate withdrawal periods
4. Maintain offline records for compliance

## Testing

### Unit Tests
```bash
# Run contract tests
clarinet test

# Test specific functions
clarinet console
```

### Integration Testing
1. Deploy to testnet
2. Test student qualification workflow
3. Verify scholarship claiming process
4. Test administrative functions
5. Validate error handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit pull request with detailed description

## Support

For technical support or questions:
- Create an issue in the repository
- Contact the development team
- Refer to Stacks documentation for blockchain-specific queries

