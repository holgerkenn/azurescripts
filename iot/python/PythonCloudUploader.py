from azure.storage import BlobService;
import sys,argparse

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
