from azure.storage import AccessPolicy, SharedAccessPolicy
from azure.storage.blob import BlobService,BlobSharedAccessPermissions
import sys,argparse,datetime

storage_account_key = ''
storage_account_name = ''
storage_container_name = ''
inputfile=''
outputblob=''
verbose=False


def main():
    #continue here

    if verbose: 
        print('Copying')
        print('Storage account:',storage_account_name)
        print('Storage Key:',storage_account_key)
        print('Container Name:',storage_container_name)
        print('Input file:',inputfile)
        print('Output Blob:',outputblob)
    blob_service = BlobService(account_name=storage_account_name, account_key = storage_account_key)
    #blob_service.create_container(storage_container_name,x_ms_blob_public_access='containter')
    blob_service.put_block_blob_from_path(storage_container_name, outputblob,inputfile,x_ms_blob_content_type="image/jpeg")
	#this access policy is valid for four minutes (now -120 seconds until now + 120 seconds) to account for clock skew
	ap= AccessPolicy(
        start = (datetime.datetime.utcnow() + datetime.timedelta(seconds=-120)).strftime('%Y-%m-%dT%H:%M:%SZ'),
        expiry = (datetime.datetime.utcnow() + datetime.timedelta(seconds=120)).strftime('%Y-%m-%dT%H:%M:%SZ'),
        permission=BlobSharedAccessPermissions.READ,
    )
    sas_token = blob_service.generate_shared_access_signature(
        container_name=storage_container_name,
        blob_name=outputblob,
        shared_access_policy=SharedAccessPolicy(ap),
    )
    url = blob_service.make_blob_url(
        container_name=storage_container_name,
        blob_name=outputblob,
        sas_token=sas_token,
    )
    print('URL is:',url)
	#even if the blob is not public, it can be accessed with this URL


if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--storagename')
    parser.add_argument('-k', '--storagekey')
    parser.add_argument('-c', '--containername')
    parser.add_argument('-v', dest='verbose', action='store_true')
    parser.add_argument('inputfile',metavar='<input>',help='file to upload');
    parser.add_argument('outputblob',metavar='<output>',help='blob to store file content');
    args = parser.parse_args()
    storage_account_key = args.storagekey
    storage_account_name = args.storagename
    storage_container_name = args.containername
    inputfile = args.inputfile
    outputblob = args.outputblob
    verbose=args.verbose
    main()
