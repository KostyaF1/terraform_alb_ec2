{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "IPAllow",
            "Effect": "Allow",
            "Principal": {
                            "Service": [
                                "ec2.amazonaws.com"
                            ]
                        },
            "Action": [
                "s3:GetObject"
                ],
            "Resource": "${ s3_resource }/*",
            "Condition": {
            "IpAddress": {
                "aws:SourceIp": ["${ ec2_addresses }"]
                }
            }
        }
    ]
}