import React, { Component } from 'react';
import { Container, Box } from '../Styles';
import ContractData from '../ContractData';
import ContractForm from '../ContractForm';

class ProofSubmission extends Component {
	constructor(props) {
		super(props);
		this.state = {};

		// TODO make this parsing more robust with errors if wrong etc. REMARK: not needed necessarily, we could render this as a popup and transfer the params as props
		var url = window.location.href;
		var params = url.split('?')[1].split('&');
		this.tokenAddress = params[0].split('=')[1];
		this.claimId = Number(params[1].split('=')[1]);
	}

	requiredProofTypeAddresses = data => {
		var tokenName = data[0];
		var tokenSymbol = data[1];
		// var claimer = data[2];
		var isApproved = data[3];
		var quantity = Number(data[4]);
		var date = Number(data[5]);
		var comment = data[6];
		var requiredProofTypes = data[7];
		var proofTypeStatuses = data[8];
		this.proofTypeStatusesObj = {};
        for (var i = 0; i < requiredProofTypes.length; i ++) {
            this.proofTypeStatusesObj[requiredProofTypes[i]] = {};
            this.proofTypeStatusesObj[requiredProofTypes[i]].approved = proofTypeStatuses[i];
        }

		this.getProofTypeInfoAndShowForm = data => {
			var address = data[0];
			var name = data[1];
            var description = data[2];
            
            var info = 
                <span>
                    <b>{name}</b>: {description}
                    <br></br>
                    <i>{address}</i>
                </span>

            if (this.proofTypeStatusesObj[address].approved) {
                return (
                    <div>
                        {info}
                        <br></br><br></br>
                        <font color="green"><b>Proof type approved</b></font>
                    </div>
                );
            }

			return (
				<div>
                    {info}
                    <br></br><br></br>
                    <font color="red"><b>Proof type not approved yet</b></font>
					<Box title={'Initiate proof for ' + name}>
						<ContractForm
							contractAddress={address}
							contractJson={name + '.json'}
							method="submitProof"
							fixArgs={{
                                tokenAdrToReceiveProof: this.tokenAddress, 
                                claimId: this.claimId + ""
                            }}
						/>
					</Box>
				</div>
			);
		};

		this.proofTypes = requiredProofTypes.map((address, index) => {
			return (
				<div key={'div_' + index}>
					<hr></hr>
					<span key={index}>
						<ContractData
							contractName="Fin4Main"
							method="getProofTypeInfo"
							methodArgs={[address]}
							callback={this.getProofTypeInfoAndShowForm}
						/>
						<br></br>
						<br></br>
					</span>
				</div>
			);
		});

		return (
			<div>
				Claim <i>{this.claimId}</i> on action type <b>{tokenName}</b> [
				{tokenSymbol}] <i>{this.tokenAddress}</i><br></br>
				<br></br>
				isApproved: <i>{isApproved + ''}</i>, quantity: <i>{quantity}</i>, date:{' '}
				<i>{date}</i>, comment: <i>{comment}</i>
				<br></br>
				<br></br>
				{this.proofTypes}
			</div>
		);
	};

	render() {
		return (
			<Container>
				<ContractData
					contractAddress={this.tokenAddress}
					method="getClaim"
					methodArgs={[this.claimId]}
					callback={this.requiredProofTypeAddresses}
				/>
			</Container>
		);
	}
}

export default ProofSubmission;