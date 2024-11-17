def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Eu verifico se o CPF informado é válido.\nEstou online!'
    }