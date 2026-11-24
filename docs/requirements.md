# PayLink Requirements (Phase 1)

CS352 Advanced Software Engineering, Cairo University FCAI.
Team: Rana Sami Rizk, Rawan Youssry Ebrahim, Manal Ezzat Ahmed, Mohammed Metwally Aboelnasr.

This file is the Markdown copy of Sections 1 to 6 of the team's Software Requirements Specification. The full report, with the design models and diagrams, is [`PayLink_Requirements_Phase1.pdf`](PayLink_Requirements_Phase1.pdf). The design models (Section 7) are in [`docs/design/`](design/). When the requirements change, update both this file and the report.

## 1. Problem Summary

PAY LINK is an Egyptian digital payment platform that provides customers with a digital wallet for paying utility bills and purchasing mobile top-ups. The system supports payments for electricity, water, mobile and internet services through external billers, and it also supports payments made through agents. Customers can register, manage wallet funds, view available and held balances, inquire about bills, and pay them without visiting service providers' offices.

The main problem addressed by PAY LINK is the need to process financial transactions accurately, securely and reliably across different billers. Since the platform holds customers' money, it must prevent duplicate charges and negative balances, record every money movement, and correctly handle failed, delayed or uncertain payment responses. Before sending a payment to a biller, the system checks applicable limits and fraud rules and places the required amount on hold. It then completes the charge only after confirmation, or releases the hold when the payment is confirmed to have failed.

PAY LINK also handles different biller communication formats, service fees, agent commissions, notifications and reconciliation against biller settlement files. Its goal is to provide a dependable and maintainable backend that can handle high transaction volumes and allow additional billers to be integrated with minimal changes to existing modules.

Technology stack (declared in Phase 1 and fixed afterwards, as the brief requires): the backend is written in C# with ASP.NET Core on .NET 9, the relational database is Microsoft SQL Server 2022, tests use xUnit, the application and database run locally with Docker and Docker Compose, and GitHub Actions builds, checks formatting and tests every push.

## 2. Stakeholders

| **Stakeholder** | **Interest / Role** |
|---|---|
| **Customers** | Register and manage their accounts and wallets, add funds, inquire about bills, make payments, view transaction history and receive notifications. |
| **Agents** | Make payments on behalf of customers through PayLink terminals and receive commissions for successful eligible transactions. |
| **Administrators** | Manage billers and services, configure fees and limits, and maintain system settings. |
| **Customer Support Employees** | Search for payments, inspect transaction histories, help resolve payment issues, and block or unblock accounts when authorized. |
| **Billers / Service Providers** | External electricity, water, mobile and internet providers that return bill inquiries, receive payment requests, send callbacks or provide settlement files. |
| **PayLink Management** | Defines business policies, monitors service performance and financial results, and ensures the platform meets business objectives. |
| **External Notification Providers** | SMS, email and push-notification services used to deliver payment confirmations, failures and other customer messages. |

## 3. User Stories

The following user stories are mapped one-to-one to FR in the PayLink project brief. Each story includes its actor, description, precondition, postcondition, acceptance criteria and representative normal and exceptional scenarios, and its priority (Must, Should or Could). Stories 1 to 15 were written by the requirements lead and stories 16 to 28 by the requirements and quality lead.

### User Story #1: Customer Registration

| **User Story ID** | US-01 (based on FR-1) |
|---|---|
| **User Story Name** | Customer Registration |
| **Actors** | Customer |
| **Description** | As a customer, I want to register for a PayLink account so that I can access wallet and bill-payment services. |
| **Precondition** | The customer is not already registered and provides the information required by the registration process. |
| **Postcondition** | A customer account is created with the Basic verification level. |
| **Acceptance Criteria** | Given a visitor provides all required valid registration information and the information is not already associated with an account, When the visitor submits the registration request, Then the system creates the customer account with Basic verification status and confirms successful registration. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The visitor enters the required registration details. | The system validates the submitted information. |
| The visitor submits the registration form. | The system creates the account with Basic verification level and returns a success confirmation. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The visitor submits missing or invalid information, or information already used by another account. | The system rejects the request, explains the validation error, and does not create a duplicate or incomplete account. |

### User Story #2: Upgrade Customer Verification Level

| **User Story ID** | US-02 (based on FR-2) |
|---|---|
| **User Story Name** | Upgrade Customer Verification Level |
| **Actors** | Customer; Administrator or authorized verification process |
| **Description** | As a customer, I want my account to be upgraded to Verified after successful verification so that I can use the higher payment limits. |
| **Precondition** | The customer has an existing Basic account and has submitted the required verification information. |
| **Postcondition** | If verification succeeds, the account's verification level becomes Verified and the applicable higher limits are used. |
| **Acceptance Criteria** | Given a customer has a Basic account and the required verification has been approved, When the authorized verification action is completed, Then the system updates the account to Verified and applies the verified-account daily limit of 30,000 EGP. |
| **Priority** | Should |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer submits the required verification information. | The system records the submitted information for verification. |
| The verification is approved. | The system changes the account level to Verified and applies the higher limits. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| Verification is rejected or required information is incomplete. | The system keeps the account at Basic level, retains the Basic limit, and informs the customer of the result. |

### User Story #3: View Wallet Balance and Transaction History

| **User Story ID** | US-03 (based on FR-3) |
|---|---|
| **User Story Name** | View Wallet Balance and Transaction History |
| **Actors** | Customer |
| **Description** | As a customer, I want to view my available balance, held balance and transaction history so that I can track my money and payments. |
| **Precondition** | The customer is registered, authenticated and has access to a wallet. |
| **Postcondition** | The system displays the wallet's available and held balances and the customer's transaction history. |
| **Acceptance Criteria** | Given an authenticated customer has a wallet, When the customer requests wallet details, Then the system displays the available balance, held balance and transaction history belonging to that customer. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer opens the wallet or transaction-history section. | The system retrieves the customer's wallet and transaction records. |
| The customer views the details. | The system displays available balance, held balance and transaction history. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer is not authenticated or requests another customer's wallet. | The system denies access and does not disclose wallet or transaction information. |

### User Story #4: Top Up Wallet

| **User Story ID** | US-04 (based on FR-4) |
|---|---|
| **User Story Name** | Top Up Wallet |
| **Actors** | Customer; Agent; Simulated Card Payment Service |
| **Description** | As a customer, I want to add money to my wallet using a simulated card payment or agent cash so that I can fund future transactions. |
| **Precondition** | The customer has an active wallet and chooses a supported top-up method. |
| **Postcondition** | If the top-up succeeds, the wallet balance is increased and the money movement is recorded. |
| **Acceptance Criteria** | Given a customer has an active wallet and submits a valid top-up through the simulated card or agent-cash method, When the top-up is confirmed, Then the system credits the wallet and records the balance change. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer selects simulated card or agent cash and enters the top-up amount. | The system validates the amount and selected method. |
| The top-up is confirmed. | The system credits the wallet and confirms the new transaction. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The amount is invalid or the simulated payment is declined. | The system rejects the top-up, leaves the wallet balance unchanged, and returns a clear failure message. |

### User Story #5: Record Every Wallet Balance Change in the Ledger

| **User Story ID** | US-05 (based on FR-5) |
|---|---|
| **User Story Name** | Record Every Wallet Balance Change in the Ledger |
| **Actors** | Customer; Agent; System |
| **Description** | As a system operator, I want every wallet balance change to create a ledger entry so that all money movements are traceable and balances can be derived from recorded entries. |
| **Precondition** | A wallet operation that changes a balance is requested, such as a top-up, hold, charge, commission or refund. |
| **Postcondition** | A corresponding ledger entry is stored, and wallet balances are derived from ledger records rather than being overwritten directly. |
| **Acceptance Criteria** | Given a valid operation changes a wallet balance, When the operation is committed, Then the system creates a corresponding ledger entry and the resulting balance can be calculated from the ledger entries. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| A valid wallet operation is initiated. | The system validates and processes the operation. |
| The operation is committed. | The system stores the ledger entry linked to the operation and reflects it in the calculated balance. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The operation fails before it is committed. | The system does not record a misleading completed money movement; any related ledger changes are rolled back or consistently compensated. |

### User Story #6: Manage Billers and Services

| **User Story ID** | US-06 (based on FR-6) |
|---|---|
| **User Story Name** | Manage Billers and Services |
| **Actors** | Administrator |
| **Description** | As an administrator, I want to add, edit and disable billers and their services so that the available payment providers and services remain up to date. |
| **Precondition** | The administrator is authenticated and authorized to manage the biller catalog. |
| **Postcondition** | The requested biller or service information is saved, updated or disabled. |
| **Acceptance Criteria** | Given an authorized administrator is managing the biller catalog, When the administrator adds, edits or disables a biller or service and submits valid data, Then the system saves the change and reflects the updated catalog status. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The administrator selects add, edit or disable for a biller or service. | The system displays the relevant fields or current details. |
| The administrator submits the change. | The system validates and saves the change, then confirms the result. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| A user without administrator rights attempts the operation, or the required data is invalid. | The system rejects the change, preserves the existing catalog data, and returns an appropriate error. |

### User Story #7: View Available Billers and Required Input Fields

| **User Story ID** | US-07 (based on FR-7) |
|---|---|
| **User Story Name** | View Available Billers and Required Input Fields |
| **Actors** | Customer |
| **Description** | As a customer, I want to view available billers and the information required by each one so that I can provide the correct details before making an inquiry or payment. |
| **Precondition** | The customer can access the biller catalog. |
| **Postcondition** | The system displays active billers, their services and the required customer input fields. |
| **Acceptance Criteria** | Given the biller catalog contains active billers and services, When the customer requests the available billers, Then the system displays the active options and the required input fields for the selected service. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer opens the bill-payment catalog. | The system retrieves active billers and services. |
| The customer selects a biller or service. | The system displays the required fields, such as meter number or phone number. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| A biller or service is disabled or unavailable. | The system does not offer it as an available payment option and informs the customer if it is selected through an outdated request. |

### User Story #8: Inquire About a Bill and View Total Amount

| **User Story ID** | US-08 (based on FR-8) |
|---|---|
| **User Story Name** | Inquire About a Bill and View Total Amount |
| **Actors** | Customer; Biller |
| **Description** | As a customer, I want to inquire about a bill and see its amount, service fee and total before paying so that I can decide whether to proceed. |
| **Precondition** | The customer has selected an active biller and provided the required valid reference information. |
| **Postcondition** | The system displays the bill amount, applicable fee and total payable amount when the inquiry succeeds. |
| **Acceptance Criteria** | Given a customer submits valid bill-reference information for an active biller, When the system receives a successful bill inquiry response, Then it calculates the applicable service fee and displays the bill amount, fee and total before payment. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer selects a biller and enters the required reference, such as a meter number. | The system validates the input and sends an inquiry to the selected biller. |
| The biller returns the amount due. | The system calculates the fee and displays the bill amount, fee and total. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The reference is invalid or the biller cannot return an inquiry result. | The system displays a clear inquiry error and does not proceed to payment. |

### User Story #9: Pay a Bill Using the Wallet

| **User Story ID** | US-09 (based on FR-9) |
|---|---|
| **User Story Name** | Pay a Bill Using the Wallet |
| **Actors** | Customer; Biller |
| **Description** | As a customer, I want to pay an inquired bill from my wallet so that I can settle the bill through PayLink. |
| **Precondition** | The customer is authenticated, the bill inquiry is valid, and the wallet has sufficient available funds for the total amount. |
| **Postcondition** | The payment is processed according to the payment lifecycle and its final or pending status is recorded for the customer. |
| **Acceptance Criteria** | Given a customer has a valid bill inquiry and sufficient available wallet funds, When the customer confirms payment, Then the system initiates the payment process, applies the required checks, reserves the payable amount and sends the payment request to the biller. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer reviews the bill amount, fee and total, then confirms payment. | The system checks the account, limits and available funds. |
| The checks pass. | The system reserves the required funds and sends the payment request to the biller. |
| The biller confirms payment. | The system completes the payment and returns a confirmation. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The wallet has insufficient funds or a required check fails. | The system rejects the payment, does not call the biller, and provides the reason to the customer. |

### User Story #10: Prevent Duplicate Payments Using Idempotency

| **User Story ID** | US-10 (based on FR-10) |
|---|---|
| **User Story Name** | Prevent Duplicate Payments Using Idempotency |
| **Actors** | Customer; System |
| **Description** | As a customer, I want repeated requests with the same idempotency key to return the original result so that network retries do not create duplicate payments or charges. |
| **Precondition** | The customer submits a payment request with an idempotency key. |
| **Postcondition** | Only one payment operation is created for that key, and repeated requests return the original result. |
| **Acceptance Criteria** | Given a payment request has already been processed with a specific idempotency key, When the same request is submitted again using the same key, Then the system returns the original payment result without creating another payment or charging the wallet again. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer submits a payment request with a new idempotency key. | The system processes the request and stores the key with the result. |
| The customer or client retries using the same key. | The system returns the stored result and does not repeat the payment operation. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The same idempotency key is reused with conflicting request data. | The system rejects the conflicting request and does not create an additional payment. |

### User Story #11: Enforce the Payment Lifecycle

| **User Story ID** | US-11 (based on FR-11) |
|---|---|
| **User Story Name** | Enforce the Payment Lifecycle |
| **Actors** | Customer; System; Biller |
| **Description** | As a system operator, I want every payment to follow only the defined lifecycle transitions so that payment statuses remain consistent and invalid state changes are prevented. |
| **Precondition** | A payment has been created and is in a defined initial or intermediate state. |
| **Postcondition** | The payment moves only to a state allowed by the lifecycle rules, and invalid transitions are rejected. |
| **Acceptance Criteria** | Given a payment is in a particular lifecycle state, When an event attempts to change its state, Then the system permits the transition only if it is defined in the project lifecycle and rejects any undefined transition. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| A payment is initiated and passes fraud and balance checks. | The system moves it from Initiated to FundsHeld. |
| The payment request is sent to the biller. | The system moves it to SentToBiller. |
| The biller confirms, refuses or does not respond before timeout. | The system moves it respectively to Completed, Failed or Unknown. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| An event attempts an undefined transition, such as completing a Rejected payment. | The system rejects the transition, preserves the current valid state and records the invalid attempt where appropriate. |

### User Story #12: Hold and Release Wallet Funds

| **User Story ID** | US-12 (based on FR-12) |
|---|---|
| **User Story Name** | Hold and Release Wallet Funds |
| **Actors** | Customer; System; Biller |
| **Description** | As a customer, I want the payment amount to be held before the biller is called and released if the payment fails so that my available balance is protected and accurate. |
| **Precondition** | The customer has sufficient available funds and a payment has passed the required checks. |
| **Postcondition** | The payable amount is held before the biller request; on confirmed failure, the hold is released back to the wallet. |
| **Acceptance Criteria** | Given a payment has passed the fraud checks and the wallet has sufficient funds, When the system prepares to call the biller, Then it moves the payable amount from available balance to held balance; if the biller confirms failure, the system releases the hold. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer confirms a valid payment. | The system moves the total payable amount from available to held balance before contacting the biller. |
| The biller confirms success. | The system converts the hold into the final charge. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The biller refuses the payment and the failure is confirmed. | The payment moves to Failed, then the system releases the held amount to the available balance and the payment moves to Refunded, following the defined lifecycle. |

### User Story #13: Handle Payment Timeouts and Unknown Status

| **User Story ID** | US-13 (based on FR-13) |
|---|---|
| **User Story Name** | Handle Payment Timeouts and Unknown Status |
| **Actors** | System; Biller; Customer |
| **Description** | As a customer, I want a payment that times out to be marked as Unknown and checked again according to the retry schedule so that uncertain payments are not incorrectly treated as failed. |
| **Precondition** | A payment has been sent to a live biller and no response is received within the 10-second timeout. |
| **Postcondition** | The payment is marked Unknown, the funds remain held, and the system performs up to three status re-queries after 1, 5 and 15 minutes before waiting for reconciliation. |
| **Acceptance Criteria** | Given a payment request has been sent to a live biller, When no response is received within 10 seconds, Then the system changes the payment status to Unknown, keeps the funds held, informs the customer that processing is ongoing, and schedules re-queries after 1, 5 and 15 minutes. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The system sends a payment request to the biller. | The system waits for a response up to the configured 10-second timeout. |
| No response arrives within the timeout. | The system marks the payment Unknown, keeps the hold, informs the customer and schedules the defined retries. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| A retry or later biller response confirms success or failure. | The system updates the payment to the corresponding valid state; it does not automatically refund an Unknown payment before confirming that the biller did not receive it. |

### User Story #14: Process TopUpNet Asynchronous Callbacks

| **User Story ID** | US-14 (based on FR-14) |
|---|---|
| **User Story Name** | Process TopUpNet Asynchronous Callbacks |
| **Actors** | TopUpNet Biller; System |
| **Description** | As a system, I want to accept asynchronous callbacks from TopUpNet and ignore duplicate callbacks so that delayed or repeated responses do not cause inconsistent payment results. |
| **Precondition** | A TopUpNet payment has been submitted and the system has stored its unique payment reference for callback matching. |
| **Postcondition** | A valid callback updates the matching payment once; duplicate callbacks are ignored and logged. |
| **Acceptance Criteria** | Given the system has received and processed a callback for a TopUpNet payment, When the same callback is received again, Then the system ignores the duplicate, does not apply the payment result twice, and logs the duplicate callback. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The system sends a TopUpNet payment request and receives an accepted response. | The system keeps the payment in the SentToBiller state and waits for the callback. |
| TopUpNet sends a success or failed callback. | The system validates and matches the callback, then updates the payment according to the lifecycle. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| TopUpNet sends the same callback more than once or sends an unmatched/invalid callback. | The system ignores duplicate callbacks and logs them; invalid or unmatched callbacks do not change a payment. |

### User Story #15: Integrate at Least Three Different Billers

| **User Story ID** | US-15 (based on FR-15) |
|---|---|
| **User Story Name** | Integrate at Least Three Different Billers |
| **Actors** | Customer; PayLink System; ElectroCo; AquaCo; TopUpNet |
| **Description** | As a customer, I want PayLink to support electricity, water and mobile top-up billers through their different communication formats so that I can pay different types of bills using one platform. |
| **Precondition** | The required biller integrations and their mock services are configured and available. |
| **Postcondition** | The system can process supported requests through ElectroCo, AquaCo and TopUpNet using each provider's required protocol and response handling. |
| **Acceptance Criteria** | Given the customer selects one of the supported billers, When the system sends an inquiry or payment request, Then it communicates using that biller's specified format: ElectroCo through REST/JSON, AquaCo through SOAP-style XML over HTTP, and TopUpNet through REST/JSON with asynchronous callbacks. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer selects an electricity, water or mobile top-up service. | The system identifies the corresponding biller integration. |
| The system sends a request to the selected biller. | The integration uses the biller's specified protocol and maps the response into the common PayLink result. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| A biller returns an error, times out or is unavailable. | The system handles the failure according to that biller's behavior without preventing the other biller integrations from operating. |

### User Story #16: Calculate the Service Fee

| **User Story ID** | US-16 (based on FR-16) |
|---|---|
| **User Story Name** | Calculate the Service Fee |
| **Actors** | Customer; Agent; System |
| **Description** | As a customer, I want the service fee to be calculated according to the rule of the selected biller so that I see the correct fee and total before paying. |
| **Precondition** | A bill inquiry succeeded for an active biller service, and the fee rules and promotion dates are available in configuration. |
| **Postcondition** | The fee is calculated using exact decimal arithmetic, shown to the customer and stored with the payment. |
| **Acceptance Criteria** | Given a valid bill amount for an active service, When the system calculates the fee, Then it applies: a fixed 2.50 EGP for electricity and water; 1.5% of the amount with a minimum of 1 EGP for mobile top-up; 2 EGP for internet bills up to and including 200 EGP and 4 EGP above 200 EGP; and a fee of 0 EGP for the promoted biller when the current date is inside the configured promotion period. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer inquires about a 350.00 EGP electricity bill. | The system applies the fixed fee and displays: amount 350.00, fee 2.50, total 352.50 EGP. |
| The customer requests a 40.00 EGP mobile top-up. | 1.5% of 40.00 is 0.60, so the system applies the 1.00 EGP minimum and displays a total of 41.00 EGP. |
| The customer inquires about a 250.00 EGP internet bill during the configured promotion period of that biller. | The system sets the fee to 0.00 EGP and displays a total of 250.00 EGP. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The promotion has not started, has already ended, or the selected biller is not the promoted one. | The system applies the standard fee rule of that service. |
| The fee rule or amount is missing or invalid. | The system does not show a total, returns a clear error and does not allow the payment to continue. |

### User Story #17: Agent Pays on Behalf of a Customer and Earns Commission

| **User Story ID** | US-17 (based on FR-17) |
|---|---|
| **User Story Name** | Agent Pays on Behalf of a Customer and Earns Commission |
| **Actors** | Agent; Customer; System; Biller |
| **Description** | As an agent, I want to pay a bill on behalf of a customer through my PayLink terminal and earn a commission so that customers who visit my shop can pay their bills. |
| **Precondition** | The agent is authenticated and has an agent wallet. The customer is identified at the terminal and has a wallet with sufficient available funds. |
| **Postcondition** | The payment is stored with the agent reference. When it reaches Completed, the agent wallet is credited with 40% of the service fee and a ledger entry is recorded. |
| **Acceptance Criteria** | Given an authenticated agent submits a valid payment on behalf of a customer, When the payment reaches the Completed state, Then the system credits the agent wallet with 40% of the service fee and records a ledger entry; if the payment does not complete, no commission is credited. |
| **Priority** | Should |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The agent identifies the customer, selects the biller and confirms a 350.00 EGP electricity payment. | The system processes the payment through the normal payment life cycle and stores the agent as the source of the payment. |
| The biller confirms the payment. | The system completes the payment and credits the agent wallet with 1.00 EGP (40% of the 2.50 EGP fee) through a ledger entry. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The payment is Rejected, Failed or still Unknown. | No commission is credited. If the payment later becomes Completed, the commission is credited at that time. |
| The fee is 0 EGP because of a promotion. | The commission is 0.00 EGP and no commission entry for a positive amount is created. |

### User Story #18: Reject Payments Above the Limits

| **User Story ID** | US-18 (based on FR-18) |
|---|---|
| **User Story Name** | Reject Payments Above the Limits |
| **Actors** | Customer; Agent; System |
| **Description** | As the business, I want payments above the single-payment limit or the daily limit to be rejected with a clear reason so that risk and abuse are limited. |
| **Precondition** | A payment request is submitted for an account with a known verification level. The limits are read from configuration: 5 EGP minimum and 10,000 EGP maximum per payment, and 5,000 EGP (Basic) or 30,000 EGP (Verified) per day. |
| **Postcondition** | A request that breaks a limit is stored as Rejected with the reason; no funds are held and the biller is not called. |
| **Acceptance Criteria** | Given an account has a daily limit based on its verification level, When a payment amount is below 5 EGP or above 10,000 EGP, or would make the total of the day exceed the daily limit, Then the system rejects the payment, does not hold funds or call the biller, and returns a message that names the limit that was exceeded. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| A Basic customer who already paid 4,900.00 EGP today requests a 200.00 EGP payment. | The total would be 5,100.00 EGP, so the system rejects the payment with the reason "daily limit exceeded". |
| A Basic customer who paid 4,800.00 EGP today requests a 200.00 EGP payment. | The total equals exactly 5,000.00 EGP, so the limit is not exceeded and the payment continues. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| A customer requests a 4.99 EGP payment or a 10,000.01 EGP payment. | The system rejects the payment with the reason "below minimum" or "above maximum single payment" and the payment is Rejected. |

### User Story #19: Block Accounts that Pay Too Fast (Velocity Rule)

| **User Story ID** | US-19 (based on FR-19) |
|---|---|
| **User Story Name** | Block Accounts that Pay Too Fast (Velocity Rule) |
| **Actors** | Customer; Agent; System |
| **Description** | As the business, I want an account that makes too many payments in a short time to be blocked temporarily so that fraud and runaway clients are stopped. |
| **Precondition** | The account is active and submits payment requests. The rule values (5 payments, 60 seconds, 10 minutes) are read from configuration. |
| **Postcondition** | When the rule is broken, the request is Rejected and the account cannot create payments for 10 minutes. |
| **Acceptance Criteria** | Given an account has submitted 5 payment requests in the last 60 seconds, When another new payment request is submitted inside the same 60 seconds, Then the system rejects it and blocks the account from creating payments for 10 minutes. |
| **Priority** | Should |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| A customer submits a sixth new payment request 40 seconds after the first one. | The system rejects the request, blocks the account for 10 minutes and tells the customer when the block ends. |
| The customer submits a new payment request 11 minutes later. | The block has expired, so the request is processed normally. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| A blocked customer tries to pay during the 10 minutes. | The system rejects the request with the reason "account temporarily blocked" and does not call the biller. |
| The client repeats a request with an idempotency key that was already used. | The repeated request returns the original result and does not count as a new payment in the velocity rule. |

### User Story #20: Search a Payment and View Its History

| **User Story ID** | US-20 (based on FR-20) |
|---|---|
| **User Story Name** | Search a Payment and View Its History |
| **Actors** | Customer Support Employee |
| **Description** | As a support employee, I want to search for a payment by its reference and see its full history so that I can investigate and resolve customer problems. |
| **Precondition** | The support employee is authenticated and authorized. The payment reference is known. |
| **Postcondition** | The payment details and the complete history are displayed. |
| **Acceptance Criteria** | Given a payment exists, When an authorized support employee searches by its reference, Then the system displays the payment details and its complete history, including every state change, biller response, notification and ledger entry with timestamps. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The support employee enters a payment reference. | The system finds the payment and displays amount, fee, biller, customer, agent (if any) and current state. |
| The support employee opens the history. | The system displays the ordered list of state changes, biller calls and responses, notifications sent and ledger entries. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The reference does not exist, or the user is not a support employee. | The system shows "payment not found" or denies access, and does not disclose any payment data. |

### User Story #21: Block and Unblock an Account

| **User Story ID** | US-21 (based on FR-21) |
|---|---|
| **User Story Name** | Block and Unblock an Account |
| **Actors** | Customer Support Employee; Customer |
| **Description** | As a support employee, I want to block and unblock a customer account so that I can stop suspicious activity and restore normal service when it is safe. |
| **Precondition** | The support employee is authenticated and authorized to manage accounts. |
| **Postcondition** | A blocked account cannot create new payments; an unblocked account can pay again. Each action is stored in the audit log with a reason. |
| **Acceptance Criteria** | Given an active customer account, When an authorized support employee blocks it with a reason, Then new payment requests from that account are rejected with the reason "account blocked" until a support employee unblocks it; payments that are already in progress are not cancelled. |
| **Priority** | Should |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The support employee selects an account and blocks it with a reason. | The system marks the account as blocked and writes an audit record. |
| The support employee unblocks the account. | The system allows new payments again and writes an audit record. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| A user without support rights tries to block an account, or the account is already blocked. | The system denies the action, or reports that the account is already blocked, and changes nothing. |

### User Story #22: Notify the Customer of the Payment Result

| **User Story ID** | US-22 (based on FR-22) |
|---|---|
| **User Story Name** | Notify the Customer of the Payment Result |
| **Actors** | Customer; System; External Notification Providers |
| **Description** | As a customer, I want to receive an SMS and a push message when my payment completes or fails so that I know the result without opening the app. |
| **Precondition** | The payment reaches the Completed or Failed state and the customer has contact details for notifications. |
| **Postcondition** | An SMS and a push notification are sent using the template of the event. The payment result does not depend on the delivery. |
| **Acceptance Criteria** | Given a payment reaches the Completed or Failed state, When the state change is saved, Then the system sends an SMS and a push notification to the customer using the message template for that event, containing the payment reference, the amount and, for a failure, a clear reason. |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| A payment is completed by the biller. | The system sends an SMS and a push message with the reference and the amount. |
| A payment is refused by the biller (Failed). | The system sends an SMS and a push message with the reason, and tells the customer that the held amount is returned. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The SMS provider is down when the payment completes. | The payment still stays Completed; the failed message is handled by the retry rule of US-23. |

### User Story #23: Retry Failed Notifications

| **User Story ID** | US-23 (based on FR-23) |
|---|---|
| **User Story Name** | Retry Failed Notifications |
| **Actors** | System; External Notification Providers |
| **Description** | As the business, I want failed SMS and email messages to be retried and finally marked undelivered so that temporary provider problems do not lose messages and permanent ones are visible. |
| **Precondition** | A notification attempt (SMS or email) failed. |
| **Postcondition** | The message is either delivered by a retry, or marked undelivered after 3 failed retries. |
| **Acceptance Criteria** | Given an SMS or email delivery attempt fails, When the failure is detected, Then the system retries delivery up to 3 times and, if all retries fail, marks the notification as undelivered, without changing the payment state. |
| **Priority** | Should |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The first delivery attempt fails. | The system schedules retry 1 and keeps the notification pending. |
| Retry 2 succeeds. | The system marks the notification as delivered and stops retrying. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| All 3 retries fail. | The system marks the notification as undelivered, records it in the log and leaves the payment Completed. |

### User Story #24: Edit Fee and Limit Values Without Redeploying

| **User Story ID** | US-24 (based on FR-24) |
|---|---|
| **User Story Name** | Edit Fee and Limit Values Without Redeploying |
| **Actors** | Administrator |
| **Description** | As an administrator, I want to edit fee values, limits and promotion dates without redeploying the system so that business rules can change quickly. |
| **Precondition** | The administrator is authenticated and authorized. Fee and limit values are stored in configuration. |
| **Postcondition** | The new values are saved, applied to new payments and written to the audit log. |
| **Acceptance Criteria** | Given an authorized administrator edits a fee value, a limit value or the promotion dates, When the new values are valid and saved, Then the system applies them to new payments without a redeploy or restart, keeps the fee of payments already created unchanged, and records who changed what and when. |
| **Priority** | Should |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The administrator changes the electricity fee from 2.50 EGP to 3.00 EGP. | The system validates and saves the value, and records the change in the audit log. |
| A customer inquires about an electricity bill after the change. | The system calculates the fee with the new value of 3.00 EGP. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The administrator enters an invalid value, such as a negative fee, a minimum above the maximum, or an end date before the start date. | The system rejects the change, keeps the previous values and returns a clear error. |

### User Story #25: Write an Audit Log for Money Movements and Admin Actions

| **User Story ID** | US-25 (based on FR-25) |
|---|---|
| **User Story Name** | Write an Audit Log for Money Movements and Admin Actions |
| **Actors** | System; Customer; Agent; Administrator; Customer Support Employee |
| **Description** | As the business, I want every money movement and admin action to be written to an audit log so that any operation can be traced to who did it, when and why. |
| **Precondition** | A money movement (top-up, hold, release, charge, fee, commission, refund) or an admin action (biller, fee, limit or account change) is performed. |
| **Postcondition** | An audit record exists for the operation. Audit records cannot be edited or deleted through the application. |
| **Acceptance Criteria** | Given a money movement or an admin action is performed, When the operation is committed, Then the system stores an audit record with who performed it, when, what changed (action, amounts, references) and why (reason or business event). |
| **Priority** | Must |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| A payment completes and the fee and commission are posted. | The system writes an audit record for each money movement, linked to the payment reference. |
| An administrator disables a biller. | The system writes an audit record with the administrator, the time, the biller and the reason. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The audit record cannot be written. | The system does not commit the operation, so no money movement exists without an audit record. |

### User Story #26: Produce the Daily Reconciliation Report

| **User Story ID** | US-26 (based on FR-26) |
|---|---|
| **User Story Name** | Produce the Daily Reconciliation Report |
| **Actors** | System; Biller; Customer Support Employee |
| **Description** | As a support employee, I want the system to compare PayLink payments with the daily settlement file of each biller and report the differences so that missing or wrong payments are found and reviewed. |
| **Precondition** | The biller settlement file for the business day is available and PayLink has the payments of that day. |
| **Postcondition** | A reconciliation report lists the matched payments and every difference. Payments in the Unknown state are resolved according to the life cycle. |
| **Acceptance Criteria** | Given a settlement file for a business day is available, When the nightly reconciliation runs, Then the system compares each settlement entry with the PayLink payments of that biller and day, and produces a report that lists matched payments and every difference: missing at PayLink, missing at the biller, amount mismatch, and status mismatch. |
| **Priority** | Should |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The nightly job reads the settlement file of a biller. | The system matches the entries with PayLink payments by reference, amount and status. |
| The file lists a payment that PayLink has as Failed. | The system flags the difference in the report for support review and does not change the payment automatically. |
| A payment is in the Unknown state and the file lists it, or the file does not contain it. | The system moves it to Completed if listed, or to Failed if not found, following the life cycle. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The settlement file is missing, empty, malformed or duplicated. | The system marks the reconciliation of that biller and day as incomplete, raises an alert, changes no payment and allows a rerun. |

### User Story #27: Request and Approve a Refund of a Completed Payment

| **User Story ID** | US-27 (based on FR-27) |
|---|---|
| **User Story Name** | Request and Approve a Refund of a Completed Payment |
| **Actors** | Customer; Customer Support Employee; System |
| **Description** | As a customer, I want to request a refund of a completed payment so that I can get my money back when a payment was made by mistake or the service was not received. |
| **Precondition** | The customer has a payment in the Completed state and submits a refund request with a reason. |
| **Postcondition** | If a support employee approves the request, the customer wallet is credited by a refund ledger entry linked to the original payment. If rejected, no money moves. |
| **Acceptance Criteria** | Given a customer has a Completed payment and submits a refund request, When a support employee approves it, Then the system credits the wallet with the amount paid by the customer through a refund ledger entry, records the action in the audit log and keeps the original payment in the Completed state. |
| **Priority** | Could |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The customer submits a refund request with a reason. | The system stores the request as pending and notifies support. |
| The support employee approves the request. | The system credits the wallet, links the refund to the payment, reverses the agent commission if any, and notifies the customer. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The payment is not Completed, or it was already refunded. | The system rejects the request with a clear reason and creates no ledger entry. |
| The support employee rejects the request. | The system keeps the wallet unchanged and informs the customer of the decision. |

### User Story #28: View Daily Totals

| **User Story ID** | US-28 (based on FR-28) |
|---|---|
| **User Story Name** | View Daily Totals |
| **Actors** | Administrator |
| **Description** | As an administrator, I want to view daily totals of payments, fees earned, commissions paid and failures per biller so that I can monitor the business. |
| **Precondition** | The administrator is authenticated and authorized. A business day is selected. |
| **Postcondition** | The totals for that day are displayed. |
| **Acceptance Criteria** | Given payments exist for a business day, When an authorized administrator requests the daily totals, Then the system displays the number and amount of payments, the fees earned, the commissions paid, and the number of failed payments per biller for that day. |
| **Priority** | Could |

#### Normal Scenario

| **Actor Action** | **System Response** |
|---|---|
| The administrator selects a date. | The system calculates the totals from the payments and ledger entries of that business day. |
| The administrator views the result. | The system displays the payments, fees, commissions and failures per biller. |

#### Exceptional Scenario

| **Actor Action** | **System Response** |
|---|---|
| The selected day has no payments, the date is in the future, or the user is not an administrator. | The system shows zero totals, rejects the future date, or denies access, respectively. |

## 4. Non-Functional Requirements

The following measurable non-functional requirements were chosen by the team. Each one has a target number and a way to verify it, so the tests and reports of Phase 2 can show the result.

| **ID** | **Category** | **Requirement** | **Measure / target** | **Verification** | **Priority** |
|---|---|---|---|---|---|
| NFR-1 | Correctness | No double charge and no negative balance in the duplicate-request and concurrency tests. | 0 duplicate charges and 0 balances below 0 EGP in the hard-case tests 1 and 4 and in a stress test of at least 1,000 concurrent payments on the same wallet. | Automated tests in CI | Must |
| NFR-2 | Performance | The system handles the expected payment load against the mock billers. | At least 100 payments per second sustained for 60 seconds, error rate below 1%, 95th percentile response time of 2 seconds or less for ElectroCo and TopUpNet submissions (AquaCo excluded because its mock is 2 to 4 seconds slow by design). | Load-test tool (for example k6 or Locust) with a report | Must |
| NFR-3 | Resilience | A biller outage does not stop payments to other billers. | While ElectroCo is down or times out, at least 99% of payment requests to AquaCo and TopUpNet still succeed. | Integration test with a failing ElectroCo mock | Must |
| NFR-4 | Modifiability | Adding a biller touches only the Biller Integration module and configuration. | 0 changed files outside the Biller Integration module and configuration in the pull request that adds a new biller (also for the ElectroCo v2 change). | Git diff of the pull request | Must |
| NFR-5 | Auditability | Every money movement and admin action has an audit record. | 100% of ledger entries and admin actions have an audit record with who, when and why. | Automated test comparing ledger entries and audit records | Must |
| NFR-6 | Testability | Domain logic is well covered by automated tests. | At least 70% line coverage on domain logic, reported on every push; the pipeline fails below 70%. | Coverage report in GitHub Actions | Must |
| NFR-7 | Money precision | All money values use exact decimal types. | 0 floating-point types in money calculations; rounding tests pass (for example 1.5% of 33.33 EGP is rounded half-up to 2 decimals). | Unit tests and code review | Must |
| NFR-8 | Security | Only authenticated users with the right role can access the data. | Every endpoint requires authentication; roles (customer, agent, support, admin) are enforced; 0 successful cross-account reads in access tests; passwords stored hashed; 0 secrets in the repository. | API tests and a secret scan in CI | Must |
| NFR-9 | Configurability | Business values are not hard-coded. | Fees, limits, timeouts, retry intervals and promotion dates are read from configuration; a changed value applies to new payments within 60 seconds without a redeploy. | Integration test and code review | Should |
| NFR-10 | Deployability | A clean clone starts with one command. | After docker compose up, the health check reports healthy within 2 minutes on a clean clone and the CI pipeline on the phase tag is green. | Clean-clone check and CI status | Should |

## 5. Priorities (Must, Should, Could)

Each functional requirement keeps the priority given in the project brief. No Must requirement was removed or downgraded. Summary: 19 Must, 7 Should and 2 Could requirements (28 in total).

| **FR** | **User story** | **Name** | **Priority** |
|---|---|---|---|
| FR-1 | US-01 | Customer Registration | Must |
| FR-2 | US-02 | Upgrade Customer Verification Level | Should |
| FR-3 | US-03 | View Wallet Balance and Transaction History | Must |
| FR-4 | US-04 | Top Up Wallet | Must |
| FR-5 | US-05 | Record Every Wallet Balance Change in the Ledger | Must |
| FR-6 | US-06 | Manage Billers and Services | Must |
| FR-7 | US-07 | View Available Billers and Required Input Fields | Must |
| FR-8 | US-08 | Inquire About a Bill and View Total Amount | Must |
| FR-9 | US-09 | Pay a Bill Using the Wallet | Must |
| FR-10 | US-10 | Prevent Duplicate Payments Using Idempotency | Must |
| FR-11 | US-11 | Enforce the Payment Lifecycle | Must |
| FR-12 | US-12 | Hold and Release Wallet Funds | Must |
| FR-13 | US-13 | Handle Payment Timeouts and Unknown Status | Must |
| FR-14 | US-14 | Process TopUpNet Asynchronous Callbacks | Must |
| FR-15 | US-15 | Integrate at Least Three Different Billers | Must |
| FR-16 | US-16 | Calculate the Service Fee | Must |
| FR-17 | US-17 | Agent Pays on Behalf of a Customer and Earns Commission | Should |
| FR-18 | US-18 | Reject Payments Above the Limits | Must |
| FR-19 | US-19 | Block Accounts that Pay Too Fast (Velocity Rule) | Should |
| FR-20 | US-20 | Search a Payment and View Its History | Must |
| FR-21 | US-21 | Block and Unblock an Account | Should |
| FR-22 | US-22 | Notify the Customer of the Payment Result | Must |
| FR-23 | US-23 | Retry Failed Notifications | Should |
| FR-24 | US-24 | Edit Fee and Limit Values Without Redeploying | Should |
| FR-25 | US-25 | Write an Audit Log for Money Movements and Admin Actions | Must |
| FR-26 | US-26 | Produce the Daily Reconciliation Report | Should |
| FR-27 | US-27 | Request and Approve a Refund of a Completed Payment | Could |
| FR-28 | US-28 | View Daily Totals | Could |

## 6. Ambiguities, Questions, and Team Decisions

While preparing the user stories, we found some points that needed clarification. The team discussed these points and agreed on the following decisions. Items 1 to 10 come from stories 1 to 15; items 11 to 26 come from stories 16 to 28 and the non-functional requirements. The tags (R..) refer to the FR numbers of the brief.

| **No.** | **Ambiguity / Question** | **Team Decision** |
|---|---|---|
| 1 | What is the difference between a Basic and a Verified customer account? **(R1)** | We agreed that customers start with a Basic account and can upgrade to a Verified account. |
| 2 | What is the daily transaction limit for customers? **(R2)** | The limit depends on the verification level: 5,000 EGP per day for Basic accounts and 30,000 EGP per day for Verified accounts. The values are kept in configuration, not in code. |
| 3 | How can customers add money to their wallets? **(R4)** | We agreed to support simulated card payments and cash deposits through agents. |
| 4 | Should every wallet transaction be recorded? **(R5)** | Yes, every balance change must be recorded in the wallet ledger. |
| 5 | How will customers know the total bill payment amount? **(R8)** | The system will show the bill amount, service fee, and total amount before payment confirmation. |
| 6 | What happens if the same payment request is sent more than once? **(R10)** | We agreed to use an idempotency mechanism to prevent duplicate payments. |
| 7 | What happens if the biller does not respond to a payment request? **(R13)** | The payment status will become Unknown, and the funds will remain held until the result is confirmed. |
| 8 | How many times should the system re-query a payment that timed out (Unknown status)? **(R13)** | We agreed to re-query after 1, 5, and 15 minutes (a maximum of three re-queries) before the payment waits for reconciliation. A payment refused by the biller (Failed) is not retried. |
| 9 | What happens if the system receives the same callback more than once? **(R14)** | The system must recognize duplicate callbacks and avoid processing the same transaction again. |
| 10 | Do all billers use the same communication protocol? **(R15)** | No. We agreed to support ElectroCo using REST/JSON, AquaCo using SOAP-style XML/HTTP, and TopUpNet using REST/JSON with asynchronous callbacks. |
| 11 | Is the 200 EGP boundary of the internet fee included in the lower tier, and how is a percentage fee rounded? **(R16)** | "Up to 200 EGP" includes 200.00 (fee 2 EGP); above 200.00 the fee is 4 EGP. Percentage fees are rounded half-up to 2 decimals using exact decimal types, then the 1 EGP minimum is applied. |
| 12 | Is the fee calculated on the bill amount or on a total that already includes other charges? **(R16)** | The fee is calculated on the bill amount returned by the biller. The total is bill amount plus fee. |
| 13 | How does the promotion work, and what happens to the agent commission when the fee is 0? **(R16)** | A promotion applies to one chosen biller between a configurable start and end date and sets the fee to 0 EGP. The commission is 40% of the fee, so it is also 0.00 EGP. |
| 14 | Whose wallet is debited when an agent pays on behalf of a customer? **(R17)** | The customer wallet is debited (the customer is identified and confirms at the terminal, details of the confirmation are out of scope in Phase 1). The agent is stored on the payment and receives the commission when it completes. This is the team’s final decision for Phase 1. |
| 15 | What happens to the commission if the payment fails or is refunded later? **(R17)** | The commission is credited only when the payment is Completed. If a Completed payment is refunded (FR-27), the commission is reversed with a ledger entry. |
| 16 | Do the limits include the fee, and which payments count in the daily limit? **(R18)** | Limits apply to the bill amount only. The daily total counts payments in FundsHeld, SentToBiller, Unknown and Completed; Rejected, Failed and Refunded payments are not counted. The day is the calendar day in Africa/Cairo time. |
| 17 | A Basic account has a 5,000 EGP daily limit but the single-payment maximum is 10,000 EGP. Which applies? **(R18)** | The stricter limit applies. A Basic customer cannot pay a bill above 5,000 EGP, and the rejection reason names the daily limit. |
| 18 | Which requests count in the velocity rule and what happens on the sixth request? **(R19)** | Every new payment request from the account counts, including requests that are later rejected, but not replays with an already used idempotency key. The sixth request in 60 seconds is rejected and the account is blocked for 10 minutes from that moment. |
| 19 | What does a block stop, and can support remove a temporary velocity block? **(R19 R21)** | A blocked account can log in and view data but cannot create new payments; payments already in progress continue. A support employee can unblock an account at any time, including a temporary velocity block. |
| 20 | Which events send notifications and through which channels? **(R22)** | Completed and Failed send an SMS and a push message (required). Unknown sends an informational "being processed" message. Email is optional and uses the same templates. |
| 21 | Does "retried 3 times" include the first attempt? **(R23)** | No. One first attempt plus 3 retries (4 attempts at most), then the notification is marked undelivered. The delay between retries is configurable. |
| 22 | Do changed fee and limit values affect payments that are already in progress? **(R24)** | No. Changes apply to new payments only. Every change is validated and written to the audit log. |
| 23 | What is the settlement file format, and what can reconciliation change? **(R26)** | The mock settlement file is a CSV with reference, amount, status and date. Reconciliation only flags differences for support review. It changes a payment only when the payment is Unknown: found in the file becomes Completed, not found becomes Failed (as in the life cycle). |
| 24 | Completed is a final state, so how can a Completed payment be refunded? **(R27)** | The refund is a separate Refund record with a ledger entry linked to the payment, approved by support. The payment stays Completed. The full amount paid by the customer (bill amount and fee) is returned and any agent commission is reversed. Reversal at the biller is handled outside the system. This is the team’s final decision for Phase 1. |
| 25 | Which time zone defines the business day for daily totals and reconciliation? **(R28)** | Africa/Cairo. |
| 26 | Is the NetCo batch integration included in Phase 1? **(R15)** | No. It is optional in the brief. The design keeps room for it as one more biller adapter. |
